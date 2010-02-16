#***************************************************************************
#            kalyptusCxxToKimono.pm -  Generates *.cs files for a Custom RealProxy
#										based smoke adaptor
#                             -------------------
#    begin                : Thurs Feb 19 12:00:00 2004
#    copyright            : (C) 2004, Richard Dale. All Rights Reserved.
#    email                : Richard_Dale@tipitina.demon.co.uk
#    author               : Richard Dale, based on the SMOKE generation code
#***************************************************************************/

#/***************************************************************************
# *                                                                         *
# *   This program is free software; you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation; either version 2 of the License, or     *
# *   (at your option) any later version.                                   *
# *                                                                         *
#***************************************************************************/

package kalyptusCxxToKimono;

use File::Path;
use File::Basename;

use Carp;
use Ast;
use kdocAstUtil;
use kdocUtil;
use Iter;
use kalyptusDataDict;

use strict;
no strict "subs";

use vars qw/
	$libname $rootnode $outputdir $opt $debug
	$methodNumber
	%builtins %typeunion %allMethods %allTypes %enumValueToType %typedeflist %maptypeslist %arraytypeslist %mungedTypeMap %csharpImports
	%skippedClasses %excludeClasses %partial_classes %operatorNames %new_classidx 
    %interfacemap %iterator_interface_map %namespace_exceptions *CLASS /;

BEGIN
{

# Types supported by the StackItem union
# Key: C++ type  Value: Union field of that type
%typeunion = (
    'void*' => 's_voidp',
    'bool' => 's_bool',
    'char' => 's_char',
    'uchar' => 's_uchar',
    'short' => 's_short',
    'ushort' => 's_ushort',
    'int' => 's_int',
    'uint' => 's_uint',
    'long' => 's_long',
    'ulong' => 's_ulong',
    'float' => 's_float',
    'double' => 's_double',
    'enum' => 's_enum',
    'class' => 's_class'
);

# Mapping for iterproto, when making up the munged method names
%mungedTypeMap = (
     'QString' => '$',
     'QString*' => '$',
     'QString&' => '$',
     'QCString' => '$',
     'QCString*' => '$',
     'QCString&' => '$',
     'QDBusObjectPath' => '$',
     'QDBusObjectPath*' => '$',
     'QDBusObjectPath&' => '$',
     'QDBusSignature' => '$',
     'QDBusSignature*' => '$',
     'QDBusSignature&' => '$',
     'char*' => '$',
     'QCOORD*' => '?',
     'QRgb*' => '?',
     'Q_UINT64' => '$',
     'Q_INT64' => '$',
     'Q_LLONG' => '$',
     'quint64' => '$',
     'qint64' => '$',
     'long long' => '$',
     'qulonglong' => '$',
     'WId' => '$',
     'Q_PID' => '$',
     'KMimeType::Ptr' => '#',
     'KMimeType::Ptr&' => '#',
     'KServiceGroup::Ptr' => '#',
     'KServiceGroup::Ptr&' => '#',
     'KService::Ptr' => '#',
     'KService::Ptr&' => '#',
     'KServiceType::Ptr' => '#',
     'KServiceType::Ptr&' => '#',
     'KSharedConfig::Ptr' => '#',
     'KSharedConfig::Ptr&' => '#',
     'KSharedConfigPtr' => '#',
     'KSharedConfigPtr&' => '#',
     'KSycocaEntry::Ptr' => '#',
     'KSycocaEntry::Ptr&' => '#',
     'Plasma::PackageStructure::Ptr' => '#',
     'Plasma::PackageStructure::Ptr&' => '#',
);

# Yes some of this is in kalyptusDataDict's ctypemap
# but that one would need to be separated (builtins vs normal classes)
%typedeflist =
(
   'GLenum' => 'int',
   'GLint' => 'int',
   'GLuint' => 'uint',
   'ksocklen_t' => 'uint',
   'mode_t'  =>  'long',
   'MSG*'  =>  'void*',
   'pid_t' => 'int',
   'QCOORD'  =>  'int',
   'QImageReader::ImageReaderError' => 'int',
   'qint16' => 'short',
   'Q_INT16' => 'short',
   'qint32' => 'int',
   'qint32&' => 'int',
   'Q_INT32' => 'int',
   'qint8' => 'char',
   'Q_INT8' => 'char',
   'Q_LONG' => 'long',
   'qreal' => 'double',
   'QRgb'  =>  'uint',
   'Qt::HANDLE' => 'uint',
   'QTSMFI'  =>  'int',
   'Qt::WFlags'  =>  'uint',
   'Qt::WState'  =>  'int',
   'quint16' => 'ushort',
   'Q_UINT16' => 'ushort',
   'quint32' => 'uint',
   'Q_UINT32' => 'uint',
   'quint8' => 'ushort',
   'Q_UINT8' => 'ushort',
   'Q_ULONG' => 'long',
   'short int' => 'short',
   'signed char' => 'char',
   'signed' => 'int',
   'signed int' => 'int',
   'signed long int' => 'long',
   'signed long' => 'long',
   'signed short' => 'short',
   'size_t' => 'int',
   'size_type'  =>  'int', # QSqlRecordInfo
   'time_t' => 'int',
   'unsigned char' => 'ushort',
   'unsigned int' => 'uint',
   'unsigned long int' => 'ulong',
   'unsigned long' => 'ulong',
   'unsigned short int' => 'ushort',
   'unsigned short' => 'ushort',
   'unsigned' => 'uint',
   'void(* )()'  =>  'void*',
   'void (*)(void* )'  =>  'void*',
   'WState'  =>  'int',
   'Plasma::PackageStructure::Ptr'  =>  'Plasma.PackageStructure',
   'KService::Ptr'  =>  'KService',
   'KSharedConfig::Ptr'  =>  'KSharedConfig',
   'KSharedConfigPtr'  =>  'KSharedConfig',
   'AnimId'  =>  'int',
   'Plasma::Phase::AnimId'  =>  'int',
   'KIO::filesize_t' => 'long',
   'long long' => 'long',
   'unsigned long long' => 'ulong'
);

# Some classes need extra info in addition to the autogenerated code.
# So they are split into two sources FooBar.cs and FooBarExtras.cs
# with the 'partial' modifier in the class definition
%partial_classes =
(
   'Akonadi::ItemModel' => '1',
   'KApplication' => '1',
   'KUniqueApplication' => '1',
   'KConfigGroup' => '1',
   'KCmdLineArgs' => '1',
   'KPluginFactory' => '1',
   'KService' => '1',
   'KTextEditor::CodeCompletionModel' => '1',
   'KTextEditor::Document' => '1',
   'KTextEditor::Factory' => '1',
   'KUrl' => '1',
   'QAbstractItemModel' => '1',
   'QApplication' => '1',
   'QBrush' => '1',
   'QByteArray' => '1',
   'QColor' => '1',
   'QCoreApplication' => '1',
   'QCursor' => '1',
   'QDBusConnectionInterface' => '1',
   'QIcon' => '1',
   'QIODevice' => '1',
   'QKeySequence' => '1',
   'QLineF' => '1',
   'QModelIndex' => '1',
   'QObject' => '1',
   'QPen' => '1',
   'QPointF' => '1',
   'QPolygon' => '1',
   'QPolygonF' => '1',
   'QRectF' => '1',
   'QRegion' => '1',
   'QSizeF' => '1',
   'QSqlQueryModel' => '1',
   'QStringListModel' => '1',
   'QTransform' => '1',
   'Qt' => '1',
   'QUrl' => '1',
   'QVariant' => '1',
);

%operatorNames =
(
    'operator^' => 'op_xor',
    'operator^=' => 'op_xor_assign',
    'operator<' => 'op_lt',
    'operator<<' => 'Write',
    'operator<=' => 'op_lte',
    'operator=' => 'op_assign',
    'operator==' => 'op_equals',
    'operator>' => 'op_gt',
    'operator>=' => 'op_gte',
    'operator>>' => 'Read',
    'operator|' => 'op_or',
    'operator|=' => 'op_or_assign',
    'operator-' => 'op_minus',
    'operator-=' => 'op_minus_assign',
    'operator--' => 'op_decr',
    'operator!' => 'op_not',
    'operator!=' => 'op_not_equals',
    'operator/' => 'op_div',
    'operator/=' => 'op_div_assign',
    'operator()' => 'op_expr',
    'operator[]' => 'op_at',
    'operator*' => 'op_mult',
    'operator*=' => 'op_mult_assign',
    'operator&' => 'op_and',
    'operator&=' => 'op_and_assign',
    'operator+' => 'op_plus',
    'operator+=' => 'op_plus_assign',
    'operator++' => 'op_incr',
);

%maptypeslist =
(
    'QMap<int, QVariant>' => 'Dictionary<int, QVariant>',
    'QMap<int, QVariant>&' => 'Dictionary<int, QVariant>',
    'QMap<QDate, QTextCharFormat>' => 'Dictionary<QDate, QTextCharFormat>',
    'QMap<QDate, QTextCharFormat>&' => 'Dictionary<QDate, QTextCharFormat>',
    'QMap<QString, KTimeZone>' => 'Dictionary<string, KTimeZone>',
    'QMap<QString, QString>' => 'Dictionary<string, string>',
    'QMap<QString, QString>&' => 'Dictionary<string, string>',
    'QMap<QString, QVariant>' => 'Dictionary<string, QVariant>',
    'QMap<QString, QVariant>&' => 'Dictionary<string, QVariant>',
    'QMap<QString, int>&' => 'Dictionary<string, int>',
    'QVariantMap&' => 'Dictionary<string, QVariant>',
    'QMap<QString, QVariant::Type>' => 'Dictionary<string, QVariant.TypeOf>',
    'Plasma::DataEngine::Data' => 'Dictionary<string, QVariant>',
    'Plasma::DataEngine::Data&' => 'Dictionary<string, QVariant>',
    'QHash<QString, QVariant>&' => 'Dictionary<string, QVariant>',
    'QHash<QString, QVariant>' => 'Dictionary<string, QVariant>',
    'QHash<QString, DataContainer*>' => 'Dictionary<string, Plasma.DataContainer>',
    'QHash<QString, Plasma::DataContainer*>' => 'Dictionary<string, Plasma.DataContainer>',
    'QHash<QUrl, Nepomuk::Variant>' => 'Dictionary<QUrl, Nepomuk.Variant>',
    'Plasma::DataEngine::SourceDict' => 'Dictionary<string, Plasma.DataContainer>',
);

%arraytypeslist =
(
    'Akonadi::AgentInstance::List' => 'List<Akonadi.AgentInstance>',
    'Akonadi::AgentType::List' => 'List<Akonadi.AgentType>',
    'Akonadi::Attribute::List' => 'List<Akonadi.Attribute>',
    'Akonadi::Collection::List' => 'List<Akonadi.Collection>',
    'Akonadi::Collection::List&' => 'List<Akonadi.Collection>',
    'Akonadi::Item::List' => 'List<Akonadi.Item>',
    'Akonadi::Item::List&' => 'List<Akonadi.Item>',
    'Akonadi::Job::List' => 'List<Akonadi.Job>',
    'Akonadi::Job::List&' => 'List<Akonadi.Job>',
    'KCompletionMatches' => 'List<string>',
    'KCompletionMatches*' => 'List<string>',
    'KCompletionMatchesList' => 'List<List<string>>',
    'KCompletionMatchesList&' => 'List<List<string>>',
    'KCompletionMatchesList*' => 'List<List<string>>',
    'KFileItemList' => 'List<KFileItem>',
    'KFileItemList*' => 'List<KFileItem>',
    'KFileItemList&' => 'List<KFileItem>',
    'KNS::Entry::List' => 'List<KNS.Entry>',
    'KPluginInfo::List' => 'List<KPluginInfo>',
    'KService::List' => 'List<KService>',
    'KServiceOfferList' => 'List<KServiceOffer>',
    'KUrl::List' => 'List<KUrl>',
    'KUrl::List*' => 'List<KUrl>',
    'KUrl::List&' => 'List<KUrl>',
    'QFileInfoList' => 'List<QFileInfo>',
    'QFileInfoList&' => 'List<QFileInfo>',
    'QList<char*>' => 'List<string>',
    'QList<char*>&' => 'List<string>',
    'QList<const char*>' => 'List<string>',
    'QList<const char*>&' => 'List<string>',
    'QList<double>' => 'List<double>',
    'QList<double>&' => 'List<double>',
    'QList<int>' => 'List<int>',
    'QList<int>&' => 'List<int>',
    'QList<uint>' => 'List<uint>',
    'QList<uint>&' => 'List<uint>',
    'QList<KAboutPerson>' => 'List<KAboutPerson>',
    'QList<KAboutTranslator>' => 'List<KAboutTranslator>',
    'QList<KActionCollection*>&' => 'List<KActionCollection>',
    'QList<KAction*>' => 'List<KAction>',
    'QList<KConfigDialogManager*>&' => 'List<KConfigDialogManager>',
    'QList<KConfigSkeleton::ItemEnum::Choice>' => 'List<KConfigSkeleton.ItemEnum.Choice>',
    'QList<KConfigSkeleton::ItemEnum::Choice>&' => 'List<KConfigSkeleton.ItemEnum.Choice>',
    'QList<Choice>' => 'List<KConfigSkeleton.ItemEnum.Choice>',
    'QList<Choice>&' => 'List<KConfigSkeleton.ItemEnum.Choice>',
    'QList<KDataToolInfo>' => 'List<KDataToolInfo>',
    'QList<KDataToolInfo>&' => 'List<KDataToolInfo>',
    'QList<KConfigDialogManager*>' => 'List<KConfigDialogManager>',
    'QList<KFileItem>' => 'List<KFileItem>',
    'QList<KFileItem>&' => 'List<KFileItem>',
#    'QList<KIO::CopyInfo>&' => 'List<KIO.CopyInfo>',
    'QList<KJob*>&' => 'List<KJob>',
    'QList<KMainWindow*>' => 'List<KMainWindow>',
    'QList<KMainWindow*>&' => 'List<KMainWindow>',
    'QList<KMultiTabBarButton*>' => 'List<KMultiTabBarButton>',
    'QList<KMultiTabBarTab*>' => 'List<KMultiTabBarTab>',
    'QList<KParts::Part*>' => 'List<KParts.Part>',
    'QList<KParts::Plugin*>' => 'List<KParts.Plugin>',
#    'QList<KParts::Plugin::PluginInfo>' => 'List<QXmlStreamNotationDeclaration>',
#    'QList<KParts::Plugin::PluginInfo>&' => 'List<QXmlStreamNotationDeclaration>',
    'QList<KParts::ReadOnlyPart*>' => 'List<KParts.ReadOnlyPart>',
    'QList<KPluginInfo>' => 'List<KPluginInfo>',
    'QList<KPluginInfo>&' => 'List<KPluginInfo>',
    'QList<KServiceOffer>&' => 'List<KServiceOffer>',
    'QList<KSSLCertificate*>&' => 'List<KSSLCertificate>',
    'QList<KToolBar*>' => 'List<KToolBar>',
    'QList<KUrl>' => 'List<KUrl>',
    'QList<KUrl>&' => 'List<KUrl>',
    'QList<KUserGroup>' => 'List<KUserGroup>',
    'QList<KUser>' => 'List<KUser>',
    'QList<KUser>&' => 'List<KUser>',
    'QList<KXMLGUIClient*>' => 'List<KXMLGUIClient>',
    'QList<KXMLGUIClient*>&' => 'List<KXMLGUIClient>',
    'QList<Plasma::Containment*>' => 'List<Plasma.Containment>',
    'QList<Plasma::Containment*>&' => 'List<Plasma.Containment>',
    'QList<Plasma::PlotColor>' => 'List<Plasma.PlotColor>',
    'QList<Plasma::PlotColor>&' => 'List<Plasma.PlotColor>',
    'QList<Plasma::SearchMatch*>' => 'List<Plasma.SearchMatch>',
    'QList<Plasma::SearchMatch*>&' => 'List<Plasma.SearchMatch>',
    'QList<Plasma::QueryMatch>' => 'List<Plasma.QueryMatch>',
    'QList<Plasma::QueryMatch>&' => 'List<Plasma.QueryMatch>',
    'Plasma::Applet::List' => 'List<Plasma.Applet>',
    'Plasma::AbstractRunner::List' => 'List<Plasma.AbstractRunner>',
    'QList<QAbstractButton*>' => 'List<QAbstractButton>',
    'QList<QActionGroup*>' => 'List<QAction>',
    'QList<QAction*>' => 'List<QAction>',
    'QList<QAction*>&' => 'List<QAction>',
    'QList<QByteArray>' => 'List<QByteArray>',
    'QList<QByteArray>*' => 'List<QByteArray>',
    'QList<QByteArray>&' => 'List<QByteArray>',
    'QList<QGraphicsItem*>' => 'List<IQGraphicsItem>',
    'QList<QGraphicsItem*>&' => 'List<IQGraphicsItem>',
    'QList<QGraphicsView*>' => 'List<QGraphicsView>',
    'QList <QGraphicsView*>' => 'List<QGraphicsView>',
    'QList<QHostAddress>' => 'List<QHostAddress>',
    'QList<QHostAddress>&' => 'List<QHostAddress>',
#    'QList<QImageTextKeyLang>' => 'List<QImageTextKeyLang>',
    'QList<QKeySequence>' => 'List<QKeySequence>',
    'QList<QKeySequence>&' => 'List<QKeySequence>',
    'QList<QListWidgetItem*>' => 'List<QListWidgetItem>',
    'QList<QListWidgetItem*>&' => 'List<QListWidgetItem>',
    'QList<QLocale::Country>' => 'List<QLocale.Country>',
    'QList<QMdiSubWindow*>' => 'List<QMdiSubWindow>',
    'QList<QModelIndex>' => 'List<QModelIndex>',
    'QList<QModelIndex>&' => 'List<QModelIndex>',
    'QList<QNetworkAddressEntry>' => 'List<QNetworkAddressEntry>',
    'QList<QNetworkCookie>' => 'List<QNetworkCookie>',
    'QList<QNetworkCookie>&' => 'List<QNetworkCookie>',
    'QList<QNetworkInterface>' => 'List<QNetworkInterface>',
#	These List types with doubles don't compile:
#    'QList<QPair<qreal, QPointF> >' => 'List<double, QPointF>',
    'QList<QPair<qreal, QPointF> >' => 'List<QPair<double, QPointF>>',
    'QList<QPair<qreal, qreal> >' => 'List<QPair<double, double>>',
#    'QList<QPair<qreal, qreal> >' => 'List<QPair<double, double>>',
    'QList<QPair<QString, QString> >' => 'List<QPair<string, string>>',
    'QList<QPair<QString, QString> >&' => 'List<QPair<string, string>>',
    'QList<QPixmap>' => 'List<QPixmap>',
    'QList<QPolygonF>' => 'List<QPolygonF>',
    'QList<QPrinterInfo>' => 'List<QPrinterInfo>',
    'QList<qreal>' => 'List<double>',
    'QList<QRectF>' => 'List<QRectF>',
    'QList<QRectF>&' => 'List<QRectF>',
    'QList<QSslCertificate>' => 'List<QSslCertificate>',
    'QList<QSslCertificate>&' => 'List<QSslCertificate>',
    'QList<QSslCipher>' => 'List<QSslCipher>',
    'QList<QSslCipher>&' => 'List<QSslCipher>',
    'QList<QSslError>' => 'List<QSslError>',
    'QList<QSslError>&' => 'List<QSslError>',
    'QList<QStandardItem*>' => 'List<QStandardItem>',
    'QList<QStandardItem*>&' => 'List<QStandardItem>',
    'QList<QStringList>' => 'List<List<string>>',
    'QList<QTableWidgetItem*>' => 'List<QTableWidgetItem>',
    'QList<QTableWidgetItem*>&' => 'List<QTableWidgetItem>',
    'QList<QTableWidgetSelectionRange>' => 'List<QTableWidgetSelectionRange>',
    'QList<QTextBlock>' => 'List<QTextBlock>',
    'QList<QTextFrame*>' => 'List<QTextFrame>',
#    'QList<QTextLayout::FormatRange>' => 'List<QTextLayout.FormatRange>',
#    'QList<QTextLayout::FormatRange>&' => 'List<QTextLayout.FormatRange>',
    'QList<QTreeWidgetItem*>' => 'List<QTreeWidgetItem>',
    'QList<QTreeWidgetItem*>&' => 'List<QTreeWidgetItem>',
    'QList<QTreeWidget*>' => 'List<QTreeWidget>',
    'QList<QTreeWidget*>&' => 'List<QTreeWidget>',
    'QList<QUndoStack*>' => 'List<QUndoStack>',
    'QList<QUndoStack*>&' => 'List<QUndoStack>',
    'QList<QUrl>' => 'List<QUrl>',
    'QList<QUrl>&' => 'List<QUrl>',
    'QList<QVariant>' => 'List<QVariant>',
    'QList<QVariant>&' => 'List<QVariant>',
    'QList<QWidget*>' => 'List<QWidget>',
    'QList<QWidget*>&' => 'List<QWidget>',
    'QList<QWebFrame*>' => 'List<QWebFrame>',
    'QList<QWebHistoryItem>' => 'List<QWebHistoryItem>',
    'QList<QWizard::WizardButton>&' => 'List<QWizard.WizardButton>',
    'QModelIndexList' => 'List<QModelIndex>',
    'QModelIndexList&' => 'List<QModelIndex>',
    'QObjectList' => 'List<QObject>',
    'QObjectList&' => 'List<QObject>',
    'QStringList' => 'List<string>',
    'QStringList*' => 'List<string>',
    'QStringList&' => 'List<string>',
    'QVariantList' => 'List<QVariant>',
    'QVariantList*' => 'List<QVariant>',
    'QVariantList&' => 'List<QVariant>',
    'QVector<QAbstractTextDocumentLayout::Selection>' => 'List<QAbstractTextDocumentLayout.Selection>',
    'QVector<Selection>' => 'List<QAbstractTextDocumentLayout.Selection>',
    'QVector<QColor>' => 'List<QColor>',
    'QVector<QColor>&' => 'List<QColor>',
    'QVector<QLineF>' => 'List<QLineF>',
    'QVector<QLineF>&' => 'List<QLineF>',
    'QVector<QLine>' => 'List<QLine>',
    'QVector<QLine>&' => 'List<QLine>',
    'QVector<QPointF>' => 'List<QPointF>',
    'QVector<QPointF>&' => 'List<QPointF>',
    'QVector<QPoint>' => 'List<QPoint>',
    'QVector<QPoint>&' => 'List<QPoint>',
    'QVector<qreal>' => 'List<double>',
    'QVector<qreal>&' => 'List<double>',
    'QVector<QRectF>' => 'List<QRectF>',
    'QVector<QRectF>&' => 'List<QRectF>',
    'QVector<QRect>' => 'List<QRect>',
    'QVector<QRect>&' => 'List<QRect>',
    'QVector<QRgb>' => 'List<uint>',
    'QVector<QRgb>&' => 'List<uint>',
    'QVector<QTextFormat>' => 'List<QTextFormat>',
    'QVector<QTextFormat>&' => 'List<QTextFormat>',
    'QVector<QTextLength>' => 'List<QTextLength>',
    'QVector<QTextLength>&' => 'List<QTextLength>',
    'QVector<QVariant>' => 'List<QVariant>',
    'QVector<QVariant>&' => 'List<QVariant>',
    'QWidgetList' => 'List<QWidget>',
    'QWidgetList&' => 'List<QWidget>',
    'QXmlStreamEntityDeclarations' => 'List<QXmlStreamEntityDeclaration>',
    'QXmlStreamNamespaceDeclarations' => 'List<QXmlStreamNamespaceDeclaration>',
    'QXmlStreamNotationDeclarations' => 'List<QXmlStreamNotationDeclaration>',
);

%interfacemap = (
'AbstractVideoOutput' => 'IAbstractVideoOutput',
'KBookmarkActionInterface' => 'IKBookmarkAction',
'KCompletionBase' => 'IKCompletionBase',
'KDevCore' => 'IKDevCore',
'KDirNotify' => 'IKDirNotify',
'KFileView' => 'IKFileView',
'KIO.SlaveBase' => 'KIO.ISlaveBase',
'KMessageHandler' => 'IKMessageHandler',
'KParts.PartBase' => 'KParts.IPartBase',
'KXMLGUIBuilder' => 'IKXMLGUIBuilder',
'KXMLGUIClient' => 'IKXMLGUIClient',
'PartBase' => 'IPartBase',
'Phonon.AbstractVideoOutput' => 'Phonon.IAbstractVideoOutput',
'Phonon.MediaNode' => 'Phonon.IMediaNode',
'Phonon::MediaNode' => 'Phonon.IMediaNode',
'QDBusContext' => 'IQDBusContext',
'QDBusPendingCall' => 'IQDBusPendingCall',
'QGraphicsItem' => 'IQGraphicsItem',
'QGraphicsLayoutItem' => 'IQGraphicsLayoutItem',
'QLayoutItem' => 'IQLayoutItem',
'QMimeSource' => 'IQMimeSource',
'QPaintDevice' => 'IQPaintDevice',
'QwAbsSpriteFieldView' => 'IQwAbsSpriteFieldView',
'QwtAbstractScale' => 'IQwtAbstractScale',
'QwtDoubleRange' => 'IQwtDoubleRange',
'QwtEventPattern' => 'IQwtEventPattern',
'QwtPlotDict' => 'IQwtPlotDict',
'QXmlContentHandler' => 'IQXmlContentHandler',
'QXmlDeclHandler' => 'IQXmlDeclHandler',
'QXmlDTDHandler' => 'IQXmlDTDHandler',
'QXmlEntityResolver' => 'IQXmlEntityResolver',
'QXmlErrorHandler' => 'IQXmlErrorHandler',
'SlaveBase' => 'ISlaveBase',
'Soprano.Error.ErrorCache' => 'Soprano.Error.IErrorCache',
'ErrorCache' => 'IErrorCache',
'MediaNode' => 'IMediaNode'
);

# Mono 1.2.4 doesn't seem to compile IEnumerable classes, so comment these
# out for now
%iterator_interface_map = (
# 'Soprano::QueryResultIterator' => 'IEnumerable<Soprano.BindingSet>',
# 'Soprano::StatementIterator' => 'IEnumerable<Soprano.Statement>',
# 'Soprano::NodeIterator' => 'IEnumerable<Soprano.Node>',
# 'Soprano::DBusQueryResultIterator' => 'IEnumerable<Soprano.BindingSet>',
# 'Soprano::DBusStatementIterator' => 'IEnumerable<Soprano.Statement>',
# 'Soprano::DBusNodeIterator' => 'IEnumerable<Soprano.Node>',
);

# Entries in this table are namespaces in C++, but map onto classes in C#
%namespace_exceptions = (
'Qt' => 1,
'KAuthorized' => 1,
'KColorUtils' => 1,
'KDE' => 1,
'KGlobal' => 1,
'KMacroExpander' => 1,
'KInputDialog' => 1,
'KStandardAction' => 1,
'KStandardGuiItem' => 1,
'KStandardShortcut' => 1,
'KStringHandler' => 1,
);

}

sub csharpImport($)
{
	my ( $classname ) = @_;
	my $classname_ptr = $classname . "*";
	if ( cplusplusToCSharp($classname_ptr) eq "" or $classname eq $main::globalSpaceClassName ) {
		return "";
	} elsif ( cplusplusToCSharp($classname_ptr) eq "ArrayList" ) {
		return "System.Collections";
	} elsif ( cplusplusToCSharp($classname_ptr) =~ /^List</ ) {
		return "System.Collections.Generic";
	} elsif ( cplusplusToCSharp($classname_ptr) eq "StringBuilder" ) {
		return "";
	} elsif ( cplusplusToCSharp($classname_ptr) eq "string" ) {
		return "";
	} elsif ( cplusplusToCSharp($classname_ptr) eq "string[][]" ) {
		return "";
#	} elsif ( cplusplusToCSharp($classname_ptr) eq "string[]" ) {
#		return "";
	} elsif ( cplusplusToCSharp($classname_ptr) =~ /^[a-z]/ ) {
		return "";
	} 
	return "";
}
	
sub cplusplusToCSharp
{
	my ( $cplusplusType )  = @_;
	my $isConst = ($cplusplusType =~ /const / or $cplusplusType !~ /[*&]/ ? 1 : 0);
	$cplusplusType =~ s/const //;
	$cplusplusType =~ s/^signed//;
	my $className = $cplusplusType;
	$className =~ s/[*&]//;
	
	if ( $cplusplusType =~ /void\*|K3Icon|KHTMLPart::PageSecurity|EditMode|QNetworkProtocolFactoryBase|QDomNodePrivate|QSqlDriverCreatorBase|QSqlFieldInfoList|QObjectUserData|QUObject|QTextParag|QWidgetMapper|QMemArray<int>|QLayoutIterator|QAuBucket|QUnknownInterface|QConnectionList/ ) {
		return ""; # Unsupported type
	} elsif ( $cplusplusType =~ /bool/ && kalyptusDataDict::ctypemap($cplusplusType) eq "int" ) {
		return "bool";
	} elsif ( $cplusplusType =~ /bool\s*[*&]/ ) {
#		return "bool";
		return "ref bool";
	} elsif ( $cplusplusType =~ /^(signed )?long$|^qint64$/) {
		return "long";
	} elsif ( $cplusplusType =~ /^quint64$/) {
		return "ulong";
	} elsif ( $cplusplusType =~ /^(signed )?long\s*[*&]$|^qint64\s*[*&]$/) {
		return "ref long";
	} elsif ( $cplusplusType =~ /^(u|unsigned )long\s*[*&]$|^quint64\s*[*&]$/) {
		return "ref ulong";
	} elsif ( $cplusplusType eq 'qlonglong') {
		return "long";
	} elsif ( $cplusplusType eq 'qulonglong') {
		return "ulong";
	} elsif ( $cplusplusType =~ /^KSharedPtr<(.*)>&?/) {
		return cplusplusToCSharp($1);
	} elsif ( $cplusplusType =~ /^QPair<(.*), (.*)>/) {
		my $generic1 = cplusplusToCSharp($1);
		my $generic2 = cplusplusToCSharp($2);
		return '' if ($generic1 eq '' || $generic2 eq '');
		return "QPair<$generic2, $generic1>";
	} elsif ( kalyptusDataDict::ctypemap($cplusplusType) =~ /^void\s*\*/ ) {
		return "int";
	} elsif ( kalyptusDataDict::ctypemap($cplusplusType) =~ /^qt_QIntValueList\*/ )
	{
		return "int[]";
	} elsif ( kalyptusDataDict::ctypemap($cplusplusType) =~ /^\s*(unsigned )?int\s*\*/
				|| $cplusplusType =~ /^(unsigned )?int[*&]$/ )
	{
#		return "int";
		return "ref int";
	} elsif ( $cplusplusType =~ /qreal[*&]$/ )
	{
#		return "double";
		return "ref double";
	} elsif ( kalyptusDataDict::ctypemap($cplusplusType) =~ /^\s*double\s*\*/
				|| $cplusplusType =~ /^double\s*[*&]$/ )
	{
#		return "double";
		return "ref double";
	} elsif ( kalyptusDataDict::ctypemap($cplusplusType) =~ /^\s*float\s*\*/
				|| $cplusplusType =~ /^float\s*[*&]$/ )
	{
#		return "double";
		return "ref float";
	} elsif ( kalyptusDataDict::ctypemap($cplusplusType) =~ /^\s*(unsigned )?short\s*\*/
				|| $cplusplusType =~ /^(unsigned )?short\s*[*&]$/ )
	{
#		return "short";
		return "ref short";
	} elsif ( $maptypeslist{$cplusplusType} ) {
		return $maptypeslist{$cplusplusType};
	} elsif ( $arraytypeslist{$cplusplusType} ) {
		return $arraytypeslist{$cplusplusType};
	} elsif ( $typedeflist{$cplusplusType} ) {
		return $typedeflist{$cplusplusType};
	} elsif ( $cplusplusType =~ /^QList<(.*)>/ ) {
		my $generic = cplusplusToCSharp($1);
		return '' if ($generic eq '');
		return "List<$generic>";
	} elsif ( $cplusplusType =~ /^QVector<(.*)>/ ) {
		my $generic = cplusplusToCSharp($1);
		return '' if ($generic eq '');
		return "List<$generic>";
	} elsif ( $cplusplusType =~ /uchar\s*[*&]/ 
				|| $cplusplusType =~ /unsigned char\s*[*&]/ ) {
		return "Pointer<byte>";
	} elsif ( $cplusplusType =~ /uchar/ ) {
		return "ushort";
	} elsif ( $cplusplusType =~ /(signed )?char\s*[*&]/ and !$isConst ) {
		return "Pointer<sbyte>";
	} elsif ( $cplusplusType =~ /QC?String/ and !$isConst ) {
		return "StringBuilder"
	} elsif ( $cplusplusType =~ /^[^<]*QString/ 
			|| $cplusplusType =~ /QCString/ 
			|| $cplusplusType =~ /^(const )?char\s*\*$/ 
			|| kalyptusDataDict::ctypemap($cplusplusType) =~ /^(const )?char\s*\*/ ) {
		return "string"
#	} elsif ( $cplusplusType =~ /QChar\s*[&\*]?/ || $cplusplusType =~ /^char$/ ) {
#		return "char"
	} elsif ( $cplusplusType =~ /QDBusObjectPath/ ) {
		return "QDBusObjectPath"
	} elsif ( $cplusplusType =~ /QDBusSignature/ ) {
		return "QDBusSignature"
	} elsif ( $cplusplusType =~ /QDBusVariant/ ) {
		return "QDBusVariant"
	} elsif ( defined $interfacemap{$className} ) {
		return $interfacemap{$className}
	} elsif ( kalyptusDataDict::ctypemap($cplusplusType) =~ /unsigned char/ ) {
		return "ushort";
	} elsif ( $typedeflist{$cplusplusType} =~ /ulong/ || $cplusplusType eq 'ulong' ) {
		return "ulong";
	} elsif ( $typedeflist{$cplusplusType} =~ /long/ || $cplusplusType eq 'long' ) {
		return "long";
	} elsif ( $typedeflist{$cplusplusType} =~ /uint/ || $cplusplusType eq 'uint' ) {
		return "uint";
	} elsif ( $typedeflist{$cplusplusType} =~ /int/  || $cplusplusType eq 'int' ) {
		return "int";
	} elsif ( $typedeflist{$cplusplusType} =~ /ushort/  || $cplusplusType eq 'ushort' ) {
		return "ushort";
	} elsif ( $typedeflist{$cplusplusType} =~ /short/ || $cplusplusType eq 'short') {
		return "short";
	} elsif ( $typedeflist{$cplusplusType} =~ /float/ || $cplusplusType eq 'float' ) {
		return "float";
	} elsif ( $typedeflist{$cplusplusType} =~ /double/ || $cplusplusType eq 'double') {
		return "double";
	} elsif ( kalyptusDataDict::ctypemap($cplusplusType) =~ /(unsigned )(.*)/ ) {
		return "u" . $2;
	} else {
		my $node;
		my $item;
		if ($className =~ /^(\w+)::(\w+)::(\w+)::(\w+)$/) {
			$node = kdocAstUtil::findRef( $rootnode, $1 );
            if (defined $node) {
				$node = kdocAstUtil::findRef( $node, $2 );
            	if (defined $node) {
					$node = kdocAstUtil::findRef( $node, $3 );
					$item = kdocAstUtil::findRef( $node, $4 ) if defined $node;
					if (defined $item && $item->{NodeType} eq 'enum') {
						if ($4 eq 'Type') {
							return "$1.$2.$3.TypeOf";
						} else {
							return "$1.$2.$3.$4";
						}
					} elsif (defined $item && ($item->{NodeType} eq 'class' || $item->{NodeType} eq 'struct')) {
						return $skippedClasses{$className} ? "" : "$1.$2.$3.$4";
					}
				}
			}
		} elsif ($className =~ /^(\w+)::(\w+)::(\w+)$/) {
			$node = kdocAstUtil::findRef( $rootnode, $1 );
            if (defined $node) {
				$node = kdocAstUtil::findRef( $node, $2 );
				$item = kdocAstUtil::findRef( $node, $3 ) if defined $node;
				if (defined $item && $item->{NodeType} eq 'enum') {
					if ($3 eq 'Type') {
						return "$1.$2.TypeOf";
					} else {
						return "$1.$2.$3";
					}
				} elsif (defined $item && ($item->{NodeType} eq 'class' || $item->{NodeType} eq 'struct')) {
					return $skippedClasses{$className} ? "" : "$1.$2.$3";
				}
			}
		} elsif ($className =~ /^(\w+)::(\w+)$/) {
			$node = kdocAstUtil::findRef( $rootnode, $1 );
			$item = kdocAstUtil::findRef( $node, $2 ) if defined $node;
			if (defined $item && $item->{NodeType} eq 'enum') {
				if ($2 eq 'Type') {
					return "$1.TypeOf";
				} else {
					return "$1.$2";
				}
			} elsif (defined $item && ($item->{NodeType} eq 'class' || $item->{NodeType} eq 'struct')) {
				return $skippedClasses{$className} ? "" : "$1.$2";
			}
		}
		if ($className =~ /^\w+$/) {
			$item = kdocAstUtil::findRef( $rootnode, $className );
			if (defined $item && ($item->{NodeType} eq 'class' || $item->{NodeType} eq 'struct')) {
				return $skippedClasses{$className} ? "" : $className;
			}
		}
		return kalyptusDataDict::ctypemap($cplusplusType);
	}

}

sub writeDoc
{
	( $libname, $rootnode, $outputdir, $opt ) = @_;

	print STDERR "Starting writeDoc for $libname...\n";

	# if no classlist is given, process all classes
	if ($main::classlist) {
		my %includeClasses;
		open DAT, "$main::classlist";
		foreach my $class (<DAT>) {
			chop($class);
			$includeClasses{$class} = 1;
		}
		close DAT;
		
		Iter::LocalCompounds( $rootnode, sub {
			my $classNode = shift;
			my $className = join( '::', kdocAstUtil::heritage($classNode) );
			$excludeClasses{$className} = 1 unless defined $includeClasses{$className};
		});
	}

	$debug = $main::debuggen;

	if (!$main::smokeInvocation) {
		$main::smokeInvocation = "SmokeInvocation"
	}

	mkpath( $outputdir ) unless -f $outputdir;

	print STDERR "Preparsing...\n";

	# Preparse flags
	Iter::LocalCompounds( $rootnode, sub { preParseFlags( shift ); } );

	# Preparse everything, to prepare some additional data in the classes and methods
	Iter::LocalCompounds( $rootnode, sub { preParseClass( shift ); } );

	# Have a look at each class again, to propagate CanBeCopied
	Iter::LocalCompounds( $rootnode, sub { propagateCanBeCopied( shift ); } );

	# Write out smokedata.cpp
	writeSmokeDataFile($rootnode);

	print STDERR "Writing *.cs...\n";

my @classlist;
push @classlist, ""; # Prepend empty item for "no class"
my %enumclasslist;
Iter::LocalCompounds( $rootnode, sub {
	my $classNode = $_[0];
	my $className = join( "::", kdocAstUtil::heritage($classNode) );
	
	return if $classNode->{NodeType} eq 'namespace';
	
	push @classlist, $className;
	$enumclasslist{$className}++ if keys %{$classNode->{enumerations}};
	$classNode->{ClassIndex} = $#classlist;
#	addImportForClass( $classNode, \%allImports, undef );
} );

%new_classidx = do { my $i = 0; map { $_ => $i++ } @classlist };

	# Generate *cs file for each class
	Iter::LocalCompounds( $rootnode, sub { 
		my $classNode = $_[0];
		my $className = join( "::", kdocAstUtil::heritage($classNode) );
		return if defined($excludeClasses{$className});
		writeClassDoc( shift ); 
	} );

	print STDERR "Done.\n";
}

=head2 preParseFlags
	Called for each class, looks for Q_DECLARE_FLAGS, and maps them to uints
=cut
sub preParseFlags
{
	my( $classNode ) = @_;
	my $className = join( "::", kdocAstUtil::heritage($classNode) );

    Iter::MembersByType ( $classNode, undef,
			sub {	
				my( $classNode, $m ) = @_;
				
				if ( $m->{NodeType} eq 'flags' ) {
	    			my $fullFlagsName = $className."::".$m->{astNodeName};
                    if (exists $typedeflist{$fullFlagsName}) {
						print("typemap for $fullFlagsName exists\n");
					}

					$typedeflist{$fullFlagsName} = 'uint';
	    			registerType( $fullFlagsName );

					# In QScriptValue::property() there is a const ref arg to a 
					# QScript::ResolveFlags argument:
					# QScriptValue property ( const QString & name, 
					#                         const ResolveFlags & mode = ResolvePrototype ) const
					# So cater for weirdness like this
					$typedeflist{"$fullFlagsName&"} = 'uint';
	    			registerType( "$fullFlagsName&" );
				}
			}, undef );

}

=head2 preParseClass
	Called for each class
=cut
sub preParseClass
{
	my( $classNode ) = @_;
	my $className = join( "::", kdocAstUtil::heritage($classNode) );

	if (	$classNode->{Deprecated} 
			|| $classNode->{NodeType} eq 'union' 
			|| $#{$classNode->{Kids}} < 0
			|| $classNode->{Access} eq "private"
			|| $classNode->{Access} eq "protected"  # e.g. QPixmap::QPixmapData
			|| $className =~ /.*Private$/  # Ignore any classes which aren't for public consumption
			|| $className =~ /.*Impl$/ 
			|| $className =~ /.*Internal.*/ 
			|| exists $classNode->{Tmpl}
			|| $className eq 'KAccelGen'
#			|| $className eq 'KDateTime::Spec'
			|| $className eq 'KDEDModule'
			|| $className eq 'KDialogButtonBox'
			|| $className eq 'KDirOperator'
			|| $className eq 'KDirSelectDialog'
			|| $className eq 'KEditListBox::CustomEditor'
			|| $className eq 'KFileFilterCombo'
			|| $className eq 'KFileMetaInfo'
			|| $className eq 'KFileMetaInfoGroup'
			|| $className eq 'KFileTreeBranch'
			|| $className eq 'KFileView'
			|| $className eq 'KFileViewSignaler'
			|| $className eq 'KGlobalSettings::KMouseSettings'
			|| $className eq 'khtml'
			|| $className eq 'khtml::DrawContentsEvent'
			|| $className eq 'khtml::MouseDoubleClickEvent'
			|| $className eq 'khtml::MouseEvent'
			|| $className eq 'khtml::MouseMoveEvent'
			|| $className eq 'khtml::MousePressEvent'
			|| $className eq 'khtml::MouseReleaseEvent'
			|| $className eq 'KIconTheme'
			|| $className eq 'KIO::NetRC'
			|| $className eq 'KMimeTypeChooserDialog'
			|| $className eq 'KParts::ComponentFactory'
			|| $className eq 'KParts::Plugin::PluginInfo'
			|| $className eq 'KProtocolInfo::ExtraField'
			|| $className eq 'KServiceTypeProfile'
			|| $className eq 'KSettings::PluginPage'
			|| $className eq 'KTimeZone::Transition'
			|| $className eq 'KTipDatabase'
			|| $className eq 'KTzfileTimeZoneData'
			|| $className eq 'KUrl::List'
			|| $className eq 'KXMLGUIClient::StateChange'
			|| $className eq 'Soprano::Backend'
			|| $className eq 'Soprano::QueryResultIteratorBackend'
			|| $className eq 'Soprano::BackendSetting'
			|| $className eq 'QAbstractTextDocumentLayout::PaintContext'
			|| $className eq 'QAbstractTextDocumentLayout::Selection'
			|| $className eq 'QAbstractUndoItem'
			|| $className eq 'QAccessibleBridgePlugin'
			|| $className eq 'QBrushData'
			|| $className eq 'QDBusObjectPath'
			|| $className eq 'QDBusSignature'
			|| $className eq 'QDBusVariant'
			|| $className eq 'QDebug'
			|| $className eq 'QImageTextKeyLang'
			|| $className eq 'QInputMethodEvent::Attribute'
			|| $className eq 'QIPv6Address'
			|| $className eq 'QLatin1String'
			|| $className eq 'QMap::const_iterator'
			|| $className eq 'QMapData'
			|| $className eq 'QMapData::Node'
			|| $className eq 'QMap::iterator'
			|| $className eq 'QMutex'
			|| $className eq 'QMutexLocker'
			|| $className eq 'QObjectData'
			|| $className eq 'QPainterPath::Element'
			|| $className eq 'QProxyModel'
			|| $className eq 'QReadLocker'
			|| $className eq 'QReadWriteLock'
			|| $className eq 'QSemaphore'
			|| $className eq 'QSharedData'
			|| $className eq 'QString'
			|| $className eq 'QStringList'
			|| $className eq 'QStyleOptionQ3DockWindow'
			|| $className eq 'QStyleOptionQ3ListView'
			|| $className eq 'QStyleOptionQ3ListViewItem'
			|| $className eq 'QSysInfo'
			|| $className eq 'QTextCodec::ConverterState'
			|| $className eq 'QTextLayout::FormatRange'
			|| $className eq 'QTextStreamManipulator'
			|| $className eq 'QThread'
			|| $className eq 'QThreadStorageData'
			|| $className eq 'QUpdateLaterEvent'
			|| $className eq 'QVariant::Handler'
			|| $className eq 'QVariant::PrivateShared'
			|| $className eq 'QVariantComparisonHelper'
			|| $className eq 'QVectorData'
			|| $className eq 'QWaitCondition'
			|| $className eq 'QWebPage::ChooseMultipleFilesExtensionOption'
			|| $className eq 'QWebPage::ChooseMultipleFilesExtensionReturn'
			|| $className eq 'QWidgetData'
			|| $className eq 'QWriteLocker'
			|| $className eq 'QX11Info' )
	{
	    print STDERR "Skipping $className\n" if ($debug);
	    print STDERR "Skipping union $className\n" if ( $classNode->{NodeType} eq 'union');
	    $skippedClasses{$className} = 1;
	    delete $classNode->{Compound}; # Cheat, to get it excluded from Iter::LocalCompounds
	    return;
	}

	my $signalCount = 0;
	my $eventHandlerCount = 0;
	my $defaultConstructor = 'none'; #  none, public, protected or private. 'none' will become 'public'.
	my $constructorCount = 0; # total count of _all_ ctors
	# If there are ctors, we need at least one public/protected one to instanciate the class
	my $hasPublicProtectedConstructor = 0;
	# We need a public dtor to destroy the object --- ### aren't protected dtors ok too ??
	my $hasPublicDestructor = 1; # by default all classes have a public dtor!
	#my $hasVirtualDestructor = 0;
	my $hasDestructor = 0;
	my $hasPrivatePureVirtual = 0;
	my $hasCopyConstructor = 0;
	my $hasPrivateCopyConstructor = 0;
	# Note: no need for hasPureVirtuals. $classNode{Pure} has that.

	if (defined $iterator_interface_map{$className}) {
		$partial_classes{$classNode->{astNodeName}} = 1;
	}

	if ($className =~ /KTextEditor::/) {
		$classNode->{Pure} = undef;
	}

	my $doPrivate = $main::doPrivate;
	$main::doPrivate = 1;
	# Look at each class member (looking for methods and enums in particular)
	Iter::MembersByType ( $classNode, undef,
		sub {

	my( $classNode, $m ) = @_;
	my $name = $m->{astNodeName};

	if( $m->{NodeType} eq "method" ) {
	    if ( $m->{ReturnType} eq 'typedef' # QFile's EncoderFn/DecoderFn callback, very badly parsed
	       ) {
		$m->{NodeType} = 'deleted';
		next;
	    }

	    print STDERR "preParseClass: looking at $className\::$name  $m->{Params}\n" if ($debug);

	    if ( $name eq $classNode->{astNodeName} ) {
		if ( $m->{ReturnType} =~ /~/  ) {
		    # A destructor
		    $hasPublicDestructor = 0 if $m->{Access} ne 'public';
		    #$hasVirtualDestructor = 1 if ( $m->{Flags} =~ "v" && $m->{Access} ne 'private' );
		    $hasDestructor = 1;
		} else {
		    # A constructor
		    $constructorCount++;
		    $defaultConstructor = $m->{Access} if ( $m->{Params} eq '' );
		    $hasPublicProtectedConstructor = 1 if ( $m->{Access} ne 'private' );

		    # Copy constructor?
		    if ( $#{$m->{ParamList}} == 0 ) {
			my $theArgType = @{$m->{ParamList}}[0]->{ArgType};
			if ($theArgType =~ /$className\s*\&/) {
			    $hasCopyConstructor = 1;
			    $hasPrivateCopyConstructor = 1 if ( $m->{Access} eq 'private' );
			}
		    }
		    # Hack the return type for constructors, since constructors return an object pointer
		    $m->{ReturnType} = $className."*";
		}
	    }

	    if ( $name =~ /~$classNode->{astNodeName}/ && $m->{Access} ne "private" ) { # not used
		$hasPublicDestructor = 0 if $m->{Access} ne 'public';
		#$hasVirtualDestructor = 1 if ( $m->{Flags} =~ "v" );
		$hasDestructor = 1;
	    }

	    if ( $m->{Flags} =~ "p" && $m->{Access} =~ /private/ ) {
                $hasPrivatePureVirtual = 1; # ouch, can't inherit from that one
	    }

	    # All we want from private methods is to check for virtuals, nothing else
	    next if ( $m->{Access} =~ /private/ );

		# Don't generate code for deprecated methods, 
		# or where the code won't compile/link for obscure reasons. Or even obvious reasons..
		if ( $m->{Deprecated} 
			# Assume only Qt classes have tr() and trUtf8() in their Q_OBJECT macro
			|| ($classNode->{astNodeName} !~ /^Q/ and $name eq 'tr')
			|| ($classNode->{astNodeName} !~ /^Q/ and $name eq 'trUtf8')
			|| $m->{ReturnType} =~ /template/ 
			|| $m->{ReturnType} =~ /QT3_SUPPORT/ 
			|| $name eq 'qt_metacast' 
			|| $name eq 'virtual_hook' 
			|| $name eq 'handle' 
			|| ($name eq 'qt_metacall')
			|| ($name eq 'metaObject')
			|| $name eq 'qWarning' 
			|| $name eq 'qCritical' 
			|| $name eq 'qDebug' 
			|| $name eq 'finalize' 
			|| ($classNode->{astNodeName} eq 'KApplication' and $name eq 'KApplication')
			|| ($classNode->{astNodeName} eq 'KUniqueApplication' and $name eq 'KUniqueApplication')
			|| ($classNode->{astNodeName} eq 'QApplication' and $name eq 'QApplication')
			|| ($classNode->{astNodeName} eq 'QCoreApplication' and $name eq 'QCoreApplication')
			|| ($classNode->{astNodeName} eq 'QBoxLayout' and $name eq 'spacing')
			|| ($classNode->{astNodeName} eq 'QBoxLayout' and $name eq 'setSpacing')
			|| ($classNode->{astNodeName} eq 'QGraphicsWidget' and $name eq 'children')
			|| ($classNode->{astNodeName} eq 'QGridLayout' and $name eq 'setSpacing')
			|| ($classNode->{astNodeName} eq 'QGridLayout' and $name eq 'spacing')
			|| ($classNode->{astNodeName} eq 'QMessageBox' and $name eq 'setWindowTitle')
			|| ($classNode->{astNodeName} eq 'TextEvent' and $name eq 'data')
			|| ($classNode->{astNodeName} eq 'KCmdLineArgs' and $name eq 'init' and $m->{ParamList}[0]->{ArgType} =~ /int/)
			|| ($classNode->{astNodeName} eq 'KConfigGroup' and $name eq 'groupImpl')
			|| ($classNode->{astNodeName} eq 'KConfigGroup' and $name eq 'setReadDefaults')
			|| ($classNode->{astNodeName} eq 'KConfigGroup' and $name eq 'KConfigGroup' && $#{$m->{ParamList}} == 1 && $m->{ParamList}[0]->{ArgType} =~ /const KConfigBase/)
			|| ($name eq 'operator<<' and $m->{ParamList}[0]->{ArgType} =~ /QDebug/ )
			|| ($name eq 'operator<<' and $m->{ParamList}[0]->{ArgType} =~ /QDataStream/ and $m->{ParamList}[1]->{ArgType} =~ /KDateTime::Spec/ )
			|| ($name eq 'operator>>' and $m->{ParamList}[0]->{ArgType} =~ /QDataStream/ and $m->{ParamList}[1]->{ArgType} =~ /KDateTime::Spec/ )
			|| ($name eq 'operator<<' and $m->{ParamList}[0]->{ArgType} =~ /QDataStream/ and $m->{ParamList}[1]->{ArgType} =~ /const KDateTime/ )
			|| ($name eq 'operator>>' and $m->{ParamList}[0]->{ArgType} =~ /QDataStream/ and $m->{ParamList}[1]->{ArgType} =~ /KDateTime/ )
			|| ($classNode->{astNodeName} eq 'KInputDialog' and $name eq 'getDouble')
			|| ($classNode->{astNodeName} eq 'KInputDialog' and $name eq 'getInteger')
			|| ($classNode->{astNodeName} eq 'KIO' and $name eq 'buildHTMLErrorString')
			|| ($classNode->{astNodeName} eq 'KJob' and $name eq 'description')
			|| ($classNode->{astNodeName} eq 'KJob' and $name eq 'KJob')
			|| ($classNode->{astNodeName} eq 'KShortcutsEditor' and $name eq 'checkGlobalShortcutsConflict')
			|| ($classNode->{astNodeName} eq 'KShortcutsEditor' and $name eq 'checkStandardShortcutsConflict')
			|| ($classNode->{astNodeName} eq 'KStandardShortcut' and $name eq 'insert')
			|| ($classNode->{astNodeName} eq 'KTzfileTimeZoneSource' and $name eq 'location')
			|| ($classNode->{astNodeName} eq 'Wallet' and $name eq 'Wallet')
			|| ($className eq 'Plasma::PaintUtils' and $name eq 'shadowText')
			|| ($classNode->{astNodeName} eq 'KMD5' and $name eq 'transform') ) 
		{
		    $m->{NodeType} = 'deleted';
			next;
		}
		
		if ($className eq 'Plasma::DataEngineScript') {
			$m->{Access} = 'public';
		}
		
		if ($className =~ /KTextEditor::/) {
			$m->{Flags} =~ s/p//;
		}

		my $argId = 0;
	    my $firstDefaultParam;
	    foreach my $arg ( @{$m->{ParamList}} ) {
		# Look for first param with a default value
		if ( defined $arg->{DefaultValue} && !defined $firstDefaultParam ) {
		    $firstDefaultParam = $argId;
		}

		if (	$arg->{ArgType} eq '...' # refuse a method with variable arguments
				|| $arg->{ArgType} eq 'const QTextItem&' # ref to a private class
				|| $arg->{ArgType} eq 'DecoderFn' # QFile's callback
				|| $arg->{ArgType} eq 'EncoderFn' # QFile's callback
				|| $arg->{ArgType} eq 'FILE*' ) # won't be able to handle that I think
		{
		    $m->{NodeType} = 'deleted';
		}
		else
		{
		    if (($m->{Access} =~ /slot/ || $m->{Access} =~ /signal/)
		        && !(defined($excludeClasses{$className}) && !($m->{Flags} =~ "v"))) {
                # The Qt moc doesn't distinguish between reference types and value types, but
				# the smoke runtime does, so register a type with '&', and then strip it off.
				# Not that registerType() here will do anything much to affect the generated
				# code
				my $type = $arg->{ArgType};
				$type =~ s/^const\s//;
				registerType( $type );
				$type =~ s/&//;
            	$arg->{NormalizedArgType} = $type;
		    }
		    # Resolve type in full, e.g. for QSessionManager::RestartHint
		    # (QSessionManagerJBridge doesn't inherit QSessionManager)
		    $arg->{ArgType} = kalyptusDataDict::resolveType($arg->{ArgType}, $classNode, $rootnode);
		    registerType( $arg->{ArgType} );
		    $argId++;
		}
	    }
	    $m->AddProp( "FirstDefaultParam", $firstDefaultParam );
	    $m->{ReturnType} = kalyptusDataDict::resolveType($m->{ReturnType}, $classNode, $rootnode) if ($m->{ReturnType});
	    registerType( $m->{ReturnType} );
	}
	elsif( $m->{NodeType} eq "enum" ) {
		if ( ! $m->{astNodeName} ) {
			$m->{Access} = 'protected';
		}
		my $fullEnumName = $className."::".$m->{astNodeName};
		if ( ($fullEnumName eq 'KMimeType::Format' and $name eq 'compression')
				|| $fullEnumName eq 'QDataStream::ByteOrder'
				|| $m->{Deprecated} ) {
		    $m->{NodeType} = 'deleted';
			next;
		}
	    
		$classNode->{enumerations}{$m->{astNodeName}} = $fullEnumName;
#		if $m->{astNodeName} and $m->{Access} ne 'private';
#		if $m->{astNodeName} ;

	    # Define a type for this enum
	    registerType( $fullEnumName );

	    # Remember that it's an enum
	    findTypeEntry( $fullEnumName )->{isEnum} = 1;
 	} elsif( $m->{NodeType} eq 'property' ) {
		if ( ($classNode->{astNodeName} eq 'QWidget' and $name eq 'Q_PROPERTY_height')
			|| ($classNode->{astNodeName} eq 'QWidget' and $name eq 'Q_PROPERTY_minimumSizeHint')
			|| ($classNode->{astNodeName} eq 'QWidget' and $name eq 'Q_PROPERTY_sizeHint')
			|| ($classNode->{astNodeName} eq 'QWidget' and $name eq 'Q_PROPERTY_visible')
			|| ($classNode->{astNodeName} eq 'QWidget' and $name eq 'Q_PROPERTY_width')
			|| ($classNode->{astNodeName} eq 'QStackedLayout' and $name eq 'Q_PROPERTY_count') )
		{
		    $m->{NodeType} = 'deleted';
			next;
		}

		if ($className eq 'Plasma::Applet' && $name eq 'Q_PROPERTY_hasConfigurationInterface') {
			$m->{WRITE} = "setHasConfigurationInterface";
		}

		# Don't generate C# code for the property's read and write methods
		my $method;
		if ( defined $m->{READ} && $m->{READ} ne '') {
			$method = kdocAstUtil::findRef( $classNode, $m->{READ} );
			if (	defined $method 
					&& $#{$method->{ParamList}} == -1 
					&& $method->{Flags} !~ 'v'
					&& $method->{Access} !~ /slots|signals/ ) 
		{
		    	$method->{NodeType} = 'deleted';
			}
		}

		if ( defined $m->{WRITE} && $m->{WRITE} ne '') {
			$method = kdocAstUtil::findRef( $classNode, $m->{WRITE} );
			if (	defined $method 
					&& $#{$method->{ParamList}} == 0 
					&& $method->{Flags} !~ 'v'
					&& $method->{Access} !~ /slots|signals/ ) 
			{
		    	$method->{NodeType} = 'deleted';
			}
		}
	} elsif ( $m->{NodeType} eq 'var' ) {
		if (	($classNode->{astNodeName} eq 'QUuid' and $name eq 'data4')
				|| ($name eq 'd')
				|| ($classNode->{astNodeName} eq 'Tab' and $name eq 'type')
				|| ($name eq 'staticMetaObject')
				|| ($className eq 'KDevelop::DocumentRangeObject' and $name eq 'm_mutex')
				|| ($classNode->{astNodeName} eq 'SlaveBase' and $name eq 'mIncomingMetaData')
				|| ($classNode->{astNodeName} eq 'SlaveBase' and $name eq 'mOutgoingMetaData') ) 
		{
			$m->{NodeType} = 'deleted';
			next;
		}

		$m->{Type} = kalyptusDataDict::resolveType($m->{Type}, $classNode, $rootnode);
	    my $varType = $m->{Type};
		$varType =~ s/const\s+(.*)\s*&/$1/;
		$varType =~ s/^\s*//;
		$varType =~ s/\s*$//;
		$varType =~ s/static\s+//;

		if ( $m->{Flags} =~ "s" ) {
			# We are interested in public static vars, like QColor::blue
			if ( $m->{Access} ne 'private'
				&& $className."::".$m->{astNodeName} ne "KSpell::modalListText" )
			{
				print STDERR "var: $m->{astNodeName} '$varType'\n" if ($debug);

				# Register the type
				registerType( $varType ); #unless (defined $excludeClasses{$className});
			} else {
				$m->{NodeType} = 'deleted';
			}
		} elsif ($m->{Access} eq 'public') {
			# Add a setter method for a public instance variable
			my $setMethod = $name;
			if ($setMethod =~ /^(\w)(.*)/) {
				my $ch = $1;
				$ch =~ tr/a-z/A-Z/;
				$setMethod = "set$ch$2";
			}

			my $node = Ast::New( $setMethod );
			$node->AddProp( "NodeType", "method" );
			# Flags of "=" for a setter method
			$node->AddProp( "Flags", "=" );
			$node->AddProp( "ReturnType", "void" );
			$node->AddProp( "Params", $varType );

			my $param = Ast::New( 1 );
			$param->AddProp( "NodeType", "param" );
			$param->AddProp( "ArgType", $varType );
			$param->AddProp( "ArgName", $name );
			$node->AddPropList( "ParamList", $param );

			kdocAstUtil::attachChild( $classNode, $node );
			$node->AddProp( "Access", "public" );

			# Register the type
			registerType( $varType );
		} else {
			# To avoid duplicating the above test, we just get rid of any other var
			$m->{NodeType} = 'deleted';
		}
	}
		},
		undef
	);
	$main::doPrivate = $doPrivate;

	print STDERR "$className: ctor count: $constructorCount, hasPublicProtectedConstructor: $hasPublicProtectedConstructor, hasCopyConstructor: $hasCopyConstructor:, defaultConstructor: $defaultConstructor, hasPublicDestructor: $hasPublicDestructor, hasPrivatePureVirtual:$hasPrivatePureVirtual\n" if ($debug);

	# Note that if the class has _no_ constructor, the default ctor applies. Let's even generate it.
	if ( !$constructorCount && $defaultConstructor eq 'none' && !$hasPrivatePureVirtual ) {
	    # Create a method node for the constructor
	    my $methodNode = Ast::New( $classNode->{astNodeName} );
	    $methodNode->AddProp( "NodeType", "method" );
	    $methodNode->AddProp( "Flags", "" );
	    $methodNode->AddProp( "Params", "" );
            $methodNode->AddProp( "ParamList", [] );
	    kdocAstUtil::attachChild( $classNode, $methodNode );

	    # Hack the return type for constructors, since constructors return an object pointer
	    $methodNode->AddProp( "ReturnType", $className."*" );
	    registerType( $className."*" );
	    $methodNode->AddProp( "Access", "public" ); # after attachChild
	    $defaultConstructor = 'public';
	    $hasPublicProtectedConstructor = 1;
	}

	# Also, if the class has no explicit destructor, generate a default one.
	if ( !$hasDestructor && !$hasPrivatePureVirtual ) {
	    my $methodNode = Ast::New( "$classNode->{astNodeName}" );
	    $methodNode->AddProp( "NodeType", "method" );
	    $methodNode->AddProp( "Flags", "" );
	    $methodNode->AddProp( "Params", "" );
	    $methodNode->AddProp( "ParamList", [] );
	    kdocAstUtil::attachChild( $classNode, $methodNode );

	    $methodNode->AddProp( "ReturnType", "~" );
	    $methodNode->AddProp( "Access", "public" );
	}

	# If we have a private pure virtual, then the class can't be instanciated (e.g. QCanvasItem)
	# Same if the class has only private constructors (e.g. QInputDialog)
	$classNode->AddProp( "CanBeInstanciated", $hasPublicProtectedConstructor 
#												&& !$hasPrivatePureVirtual
												&& (!$classNode->{Pure} or $classNode->{astNodeName} eq 'QValidator')
												&& !($classNode->{NodeType} eq 'namespace')
												&& ($classNode->{astNodeName} !~ /^DrawContentsEvent$|^MouseEvent$|^MouseDoubleClickEvent$|^MouseMoveEvent$|^MouseReleaseEvent$|^MousePressEvent$/)
												&& ($classNode->{astNodeName} !~ /QMetaObject|QDragObject|Slave|CopyJob|KMdiChildFrm|KNamedCommand/) );

	# We will derive from the class only if it has public or protected constructors.
	# (_Even_ if it has pure virtuals. But in that case the *.cpp class can't be instantiated either.)
	$classNode->AddProp( "BindingDerives", $hasPublicProtectedConstructor );

	# We need a public dtor to destroy the object --- ### aren't protected dtors ok too ??
	$classNode->AddProp( "HasPublicDestructor", $hasPublicDestructor );

	# Hack for QAsyncIO. We don't implement the "if a class has no explicit copy ctor,
	# then all of its member variables must be copiable, otherwise the class isn't copiable".
	$hasPrivateCopyConstructor = 1 if ( $className eq 'QAsyncIO' );

	# Remember if this class can't be copied - it means all its descendants can't either
	$classNode->AddProp( "CanBeCopied", !$hasPrivateCopyConstructor );
	$classNode->AddProp( "HasCopyConstructor", $hasCopyConstructor );
	if ($classNode->{astNodeName} =~ /Abstract/
		|| $classNode->{astNodeName} eq 'QAccessibleInterface'
		|| $classNode->{astNodeName} eq 'QAccessibleApplication'
		|| $classNode->{astNodeName} eq 'QAccessibleObjectEx'
		|| $classNode->{astNodeName} eq 'QAccessibleWidgetEx'
		|| $classNode->{astNodeName} eq 'QAccessibleObject' ) 
 	{
		$classNode->AddProp( "Pure", 1 );
	}
}

sub propagateCanBeCopied($)
{
	my $classNode = shift;
	my $className = join( "::", kdocAstUtil::heritage($classNode) );
	my @super = superclass_list($classNode);
	# A class can only be copied if none of its ancestors have a private copy ctor.
	for my $s (@super) {
	    if (!$s->{CanBeCopied}) {
		$classNode->{CanBeCopied} = 0;
		print STDERR "$classNode->{astNodeName} cannot be copied\n" if ($debug);
		last;
	    }
	}

	# Prepare the {case} dict for the class
	prepareCaseDict( $classNode );
}

sub generateClass($$$$$)
{
	my( $node, $packagename, $namespace, $indent, $addImport ) = @_;
	my $className = join( "::", kdocAstUtil::heritage($node) );
	my $csharpClassName = $node->{astNodeName};
	my $classCode = "";
	my %csharpMethods = ();
#	my %addImport = ();
	
	my @ancestors = ();
	my @ancestor_nodes = ();
	Iter::Ancestors( $node, $rootnode, undef, undef, sub { 
				my ( $ances, $name, $type, $template ) = @_;
				if ( 	$name ne "khtml::KHTMLWidget"
						and $name !~ /QList</ and $name ne 'QList' and $name !~ /QVector/ 
                        and $name !~ /QMap/ and $name !~ /QHash/
                        and $name ne 'KShared' and $name ne 'QSharedData' and $name ne '' ) {
					if (defined $ances) {
						push @ancestor_nodes, $ances;
						my $ancestorName = join( ".", kdocAstUtil::heritage($ances) );
						push @ancestors, $ancestorName;
					}
				}
			},
			undef
		);
	my @all_ancestor_nodes = superclass_list( $node );
        
	my ($methodCode, $staticMethodCode, $interfaceCode, $proxyInterfaceCode, $signalCode, $extraCode, $enumCode, $notConverted) = generateAllMethods( $node, $#ancestors + 1, 
																		\%csharpMethods, 
																		$node, 
																		1, 
																		$addImport );

	my $tempMethodNumber = $methodNumber;
	
	# Add method calls for the interfaces implemented by the class
	foreach my $ancestor_node ( @all_ancestor_nodes ) {
		if ( defined $interfacemap{$ancestor_node->{astNodeName}} && ($#ancestors > 0) ) {
			my ($meth, $static, $interf, $proxyInterf, $sig, $extra, $enum, $notconv) = generateAllMethods( $ancestor_node, 0, \%csharpMethods, $node, 0, $addImport );
			$methodCode .= $meth;
			$staticMethodCode .= $static;
			$extraCode .= $extra;
			$enumCode .= $enum;
			$interfaceCode .= $interf;
			$proxyInterfaceCode .= $proxyInterf;
			$notConverted .= $notconv;
		}
	}
	
	my $globalSpace = kdocAstUtil::findRef( $rootnode, $main::globalSpaceClassName );
	my ($meth, $static, $interf, $proxyInterf, $sig, $extra, $enum, $notconv) = generateAllMethods( $globalSpace, 0, \%csharpMethods, $node, 0, $addImport );
	$methodCode .= $meth;
	$staticMethodCode .= $static;
	$extraCode .= $extra;
	$enumCode .= $enum;
	$interfaceCode .= $interf;
	$proxyInterfaceCode .= $proxyInterf;
	$notConverted .= $notconv;
	$methodNumber = $tempMethodNumber;
		
	if ( $className eq 'Qt' ) {
		;
	} else {
		if ( $className eq 'QListViewItem' 
			|| $className eq 'QAbstractTextDocumentLayout' 
			|| $className eq 'QUriDrag' 
			||  $className eq 'KDE' ) {
			# Special case these two classes as they have methods that use ArrayList added as 'extras'
	    	$classCode .= "$indent    using System.Collections.Generic;\n";
		}

		if ( $className eq 'QObject' ) {
	    	$classCode .= "$indent    using System.Reflection;\n";
		}
	}

	if ( $enumCode ne '' ) {
		$classCode .= "$enumCode" if ($node->{NodeType} eq 'namespace' 
										&& !defined $namespace_exceptions{$csharpClassName});
	}

	if ( defined $interfacemap{$csharpClassName} ) {
		$classCode .= "\n$indent    public interface " . $interfacemap{$csharpClassName};
		my $i = 0;
		foreach my $ancestor_node ( @ancestor_nodes ) {
			if ($i > 0) {
				$classCode .= ", " 
			} else {
				$classCode .= " : "
			}
			$classCode .= $interfacemap{$ancestor_node->{astNodeName}};
			$i++;
		}
		$classCode .= " {\n";
		$classCode .= $interfaceCode;
		$classCode .= "$indent    }\n";
	}
	
	my $classdec = "";
	my $parentClassName = "";

	if ($node->{NodeType} eq 'namespace') {
		$classdec .= "    [SmokeClass(\"$className\")]\n";
#		$classdec .= "    namespace $className {\n";

		$csharpClassName = 'Global' unless $namespace_exceptions{$csharpClassName};

		if ( $partial_classes{$className} ) {
			$classdec .= "    public partial class $csharpClassName {\n";
		} else {
			$classdec .= "    public class $csharpClassName {\n";
		}

		if ( $csharpClassName eq 'Qt' ) {
			$classdec .= "        protected SmokeInvocation interceptor = null;\n";
		}
	} elsif ( $#ancestors < 0 ) {
		$classdec .= "    [SmokeClass(\"$className\")]\n";

		if ( $csharpClassName eq 'QObject' ) {
			$classdec .= "    public partial class QObject : Qt, IDisposable {\n";
			$classdec .= "        private IntPtr smokeObject;\n";
			$classdec .= "        protected Object Q_EMIT = null;\n";
			$classdec .= "        protected $csharpClassName(Type dummy) {\n";
			$classdec .= "            try {\n";
			$classdec .= "                Type proxyInterface = Qyoto.GetSignalsInterface(GetType());\n";
			$classdec .= "                SignalInvocation realProxy = new SignalInvocation(proxyInterface, this);\n";
			$classdec .= "                Q_EMIT = realProxy.GetTransparentProxy();\n";
			$classdec .= "            }\n";
			$classdec .= "            catch {\n";
			$classdec .= "                Console.WriteLine(\"Could not retrieve signal interface\");\n";
			$classdec .= "            }\n";
			$classdec .= "        }\n";
			$classdec .= "        [SmokeMethod(\"metaObject()\")]\n";
			$classdec .= "        public virtual QMetaObject MetaObject() {\n";
			$classdec .= "            if (SmokeMarshallers.IsSmokeClass(GetType())) {\n";
			$classdec .= "                return (QMetaObject) interceptor.Invoke(\"metaObject\", \"metaObject()\", typeof(QMetaObject));\n";
			$classdec .= "            } else {\n";
			$classdec .= "                return Qyoto.GetMetaObject(this);\n";
			$classdec .= "            }\n";
			$classdec .= "        }\n";
		} else {
			if ( $node->{Pure} ) {
				$classdec .= "    public abstract ";
			} else {
				$classdec .= "    public ";
			}

			if ( $partial_classes{$className} ) {
				$classdec .= "partial class $csharpClassName : Object";
			} else {
				$classdec .= "class $csharpClassName : Object";
			}
			if ( defined $interfacemap{$csharpClassName} ) {
				$classdec .= ", " . $interfacemap{$csharpClassName};
			}
			
			if ($node->{CanBeInstanciated} and $node->{HasPublicDestructor} and !$node->{Pure}) {
				$classdec .= ", IDisposable";
			}
			
			if (defined $iterator_interface_map{$className}) {
				$classdec .= ", $iterator_interface_map{$className}";
			}

			$classdec .= " {\n        protected SmokeInvocation interceptor = null;\n";
			$classdec .= "        private IntPtr smokeObject;\n";
			$classdec .= "        protected $csharpClassName(Type dummy) {}\n";
		}
	} else {
		$classdec .= "    [SmokeClass(\"$className\")]\n";
		if ( $partial_classes{$className} ) {
			if ( $node->{Pure} 
				|| $csharpClassName eq 'QAccessibleInterface'
				|| $csharpClassName eq 'QAccessibleApplication'
				|| $csharpClassName eq 'QAccessibleObjectEx'
				|| $csharpClassName eq 'QAccessibleWidgetEx'
				|| $csharpClassName eq 'QAccessibleObject' ) 
			{
				$classdec .= "    public abstract partial class $csharpClassName : ";
			} else {
				$classdec .= "    public partial class $csharpClassName : ";
			}
		} else {
			if ( $node->{Pure} ) {
				$classdec .= "    public abstract class $csharpClassName : ";
			} else {
				$classdec .= "    public class $csharpClassName : ";
			}
		}
		my $ancestor;
		foreach $ancestor ( @ancestors ) {
			if ( !defined $interfacemap{$ancestor} or $ancestor eq @ancestors[$#ancestors] ) {
				$parentClassName .= "$ancestor";
				$classdec .= "$ancestor";
				last;
			}
		}

		my @implements = ();
		if ( $#ancestors >= 1 ) {
			foreach $ancestor ( @ancestors ) {
				if ( defined $interfacemap{$ancestor} ) {
					push(@implements, $interfacemap{$ancestor});
				}
			}
	    }
	
		if ($#implements >= 0) {
			$classdec .= ", ";
			$classdec .= join(", ", @implements);
		}
		
		if ($node->{CanBeInstanciated} and $node->{HasPublicDestructor} and !$node->{Pure}) {
			$classdec .= ", IDisposable";
		}

		if (defined $iterator_interface_map{$className}) {
			$classdec .= ", $iterator_interface_map{$className}";
		}
		
		$classdec .= " {\n";
		$classdec .= "        protected $csharpClassName(Type dummy) : base((Type) null) {}\n";
	}
	
	if ( $csharpClassName !~ /^Q/ or $signalCode ne '' ) {
		my $signalLink = '';
 		if ( $signalCode ne '' ) {
			$signalLink = " See <see cref=\"I$csharpClassName" . "Signals\"></see> for signals emitted by $csharpClassName\n";
		}
		my $docnode = $node->{DocNode};
		if ( defined $docnode ) { 
			my $comment = printCSharpdocComment( $docnode, "", "$indent    /// ", $signalLink ); 
			$classCode .= $comment;
		} else {
			$classCode .= "$indent    ///$signalLink";
		}
	}
	
	$classCode .= indentText($indent, $classdec);

	# only generate nested classes
	if ($node->{NodeType} ne 'namespace') {
# 		Iter::MembersByType ( $node, undef,
# 			sub {	my ($node, $subclassNode ) = @_;
# 				if ( $subclassNode->{NodeType} =~ /class|struct/ && !defined $subclassNode->{Compound} ) {
# 					$classCode .= generateClass($subclassNode, $packagename, $namespace, $indent . "    ", $addImport);
# 				}
# 			}, undef );
	
		Iter::MembersByType ( $node, undef,
			sub {	my ($node, $subclassNode ) = @_;
				if ( $subclassNode->{NodeType} =~ /class|struct/ && $subclassNode->{Compound} ) {
					$classCode .= generateClass($subclassNode, $packagename, $namespace, $indent . "    ", $addImport);
				}
			}, undef );
	}
    
	if ($methodCode ne '') {
		if ( $#ancestors < 0 ) {
			$classCode .= "$indent        protected void CreateProxy() {\n";
		} else {
			$classCode .= "$indent        protected new void CreateProxy() {\n";
		}
		$classCode .= "$indent            interceptor = new $main::smokeInvocation(typeof($csharpClassName), this);\n$indent        }\n";
	}

	if ($proxyInterfaceCode ne '') {
		$classCode .= "$indent        private static SmokeInvocation staticInterceptor = null;\n";
		$classCode .= "$indent        static $csharpClassName() {\n";
		$classCode .= "$indent            staticInterceptor = new $main::smokeInvocation(typeof($csharpClassName), null);\n";
		$classCode .= "$indent        }\n";
	}

	if ( $enumCode ne '' ) {
		$classCode .= indentText("$indent    ", "$enumCode") unless ($node->{NodeType} eq 'namespace'
																	&& !defined $namespace_exceptions{$csharpClassName});
	}
	$classCode .= indentText($indent, $extraCode);
	$classCode .= indentText($indent, $notConverted);	
	$classCode .= indentText($indent, $methodCode);	
	$classCode .= indentText($indent, $staticMethodCode);	

 	if ( is_kindof($node, "QObject") ) {
		if ( $csharpClassName eq 'QObject' ) {
			$classCode .= "$indent        protected I" . $csharpClassName . "Signals Emit {\n";
		} else {
			$classCode .= "$indent        protected new I" . $csharpClassName . "Signals Emit {\n";
		}

		$classCode .= "$indent            get { return (I" . $csharpClassName . "Signals) Q_EMIT; }\n";
		$classCode .= "$indent        }\n";
    	$classCode .= "$indent    }\n";

		$classCode .= "\n$indent    public interface I$csharpClassName" . "Signals";
		if ($parentClassName =~ /(.*)[.](.*)/) {
			$classCode .= " : $1.I" . $2 . "Signals" unless $csharpClassName eq "QObject";
		} else {
			$classCode .= " : I" . $parentClassName . "Signals" unless $csharpClassName eq "QObject";
		}
		$classCode .= " {\n";
		$classCode .= $signalCode;
		$classCode .= "$indent    }\n";
	} else {
    	$classCode .= "$indent    }\n";
	}

	return $classCode;
}

=head2 writeClassDoc

	Called by writeDoc for each class to be written out

=cut

sub writeClassDoc
{
	my( $node ) = @_;

	my $className = join( "::", kdocAstUtil::heritage($node) );
	my $csharpClassName = $node->{astNodeName};
	# Makefile doesn't like '::' in filenames, so use __
	my $fileName  = $className;
	$fileName =~ s/::/_/g;
#	my $fileName  = join( "__", kdocAstUtil::heritage($node) );
	print "Enter: $className\n" if $debug;

	my $packagename;
	if ($className =~ /^Qsci/) {
		$packagename = "QScintilla";
	} elsif ($className =~ /^Qwt/) {
		$packagename = "Qwt";
	} elsif ($className =~ /^Q/) {
		$packagename = "Qyoto";
	} elsif ($className =~ /^Plasma/) {
		$packagename = "Plasma";
	} elsif ($className =~ /^Phonon/) {
		$packagename = "Phonon";
	} elsif ($className =~ /^Soprano/) {
		$packagename = "Soprano";
	} elsif ($className =~ /^Blitz/) {
		$packagename = "QImageBlitz";
	} else {
		$packagename = "Kimono";
	}

	my $namespace, my @parentClasses;
	my $first = 1;
	
	foreach my $n (kdocAstUtil::refHeritage($node)) {
		if ($n->{NodeType} eq 'namespace') {
			$namespace .= "." if !$first;
			$namespace .= "$n->{astNodeName}"
		} else {
			push @parentClasses, $n->{astNodeName} if $n != $node;
		}
		$first = 0;
	}

	# nested classes go into the same source file as the containing class
	return if (scalar(@parentClasses) > 0);

	my %addImport = ();

	# Write out the *.csharp file
	my $classFile = "$outputdir/$fileName.cs";
	open( CLASS, ">$classFile" ) || die "Couldn't create $classFile\n";
	print STDERR "Writing $fileName.csharp\n" if ($debug);
	
	print CLASS "//Auto-generated by kalyptus. DO NOT EDIT.\n";
#	print CLASS "//Auto-generated by $0. DO NOT EDIT.\n";
	
	$namespace = undef if defined $namespace_exceptions{$csharpClassName};
	# only the core classes go into the Kimono namespace, others have there own one.
	if (defined $namespace) {
		print CLASS "namespace $namespace {\n";
		print CLASS "    using $packagename;\n";
	} else {
		print CLASS "namespace $packagename {\n";
	}

	print CLASS "    using System;\n";

    my $classCode = generateClass($node, $packagename, $namespace, "", \%addImport);

	foreach my $imp (keys %addImport) {
		die if $imp eq '';
		# Ignore any imports for classes in the same package as the current class
		if ($imp !~ /$packagename/) {
			print CLASS "    using $imp;\n";
		}
	}	

	print CLASS $classCode;

	print CLASS "}\n";

	close CLASS;
}


# Generate the prototypes for a method (one per arg with a default value)
# Helper for makeprotos
sub iterproto($$$$$) {
    my $classidx = shift; # to check if a class exists
    my $method = shift;
    my $proto = shift;
    my $idx = shift;
    my $protolist = shift;

    my $argcnt = scalar @{ $method->{ParamList} } - 1;
    if($idx > $argcnt) {
	push @$protolist, $proto;
	return;
    }
    if(defined $method->{FirstDefaultParam} and $method->{FirstDefaultParam} <= $idx) {
	push @$protolist, $proto;
    }

    my $arg = $method->{ParamList}[$idx]->{ArgType};

    my $typeEntry = findTypeEntry( $arg );
    my $realType = $typeEntry->{realType};

    # A scalar ?
    $arg =~ s/\bconst\b//g;
    $arg =~ s/\s+//g;
    if($typeEntry->{isEnum} || $allTypes{$realType}{isEnum} || exists $typeunion{$realType} || exists $mungedTypeMap{$arg})
    {
	my $id = '$'; # a 'scalar
	$id = '?' if $arg =~ /[*&]{2}/;
	$id = $mungedTypeMap{$arg} if exists $mungedTypeMap{$arg};
	iterproto($classidx, $method, $proto . $id, $idx + 1, $protolist);
	return;
    }

    # A class ?
    if(exists $classidx->{$realType}) {
	iterproto($classidx, $method, $proto . '#', $idx + 1, $protolist);
	return;
    }

    # A non-scalar (reference to array or hash, undef)
    iterproto($classidx, $method, $proto . '?', $idx + 1, $protolist);
    return;
}

# Generate the prototypes for a method (one per arg with a default value)
sub makeprotos($$$) {
    my $classidx = shift;
    my $method = shift;
    my $protolist = shift;
    iterproto($classidx, $method, $method->{astNodeName}, 0, $protolist);
}

# Return the string containing the signature for this method (without return type).
# If the 2nd arg is not the size of $m->{ParamList}, this method returns a
# partial signature (this is used to handle default values).
sub argsSignature($$) {
    my $method = shift;
    my $last = shift;
#    my $sig = $method->{astNodeName};
    my $sig = "";
    my @argTypeList;
    my $argId = 0;
    foreach my $arg ( @{$method->{ParamList}} ) {
	last if $argId > $last;
	(my $argType = $arg->{ArgType}) =~ s/,\s+/,/g;  # Remove space after comma in templates
	push @argTypeList, $argType;
	$argId++;
    }
    $sig .= "(". join(", ",@argTypeList) .")";
    $sig .= " const" if $method->{Flags} =~ "c";
    return $sig;
}

# Return the string containing the signature for this method (without return type).
# If the 2nd arg is not the size of $m->{ParamList}, this method returns a
# partial signature (this is used to handle default values).
sub methodSignature($$) {
    my $method = shift;
    my $last = shift;
    my $sig = $method->{astNodeName};
    my @argTypeList;
    my $argId = 0;
    foreach my $arg ( @{$method->{ParamList}} ) {
	last if $argId > $last;
	(my $argType = $arg->{ArgType}) =~ s/,\s+/,/g;  # Remove space after comma in templates
	push @argTypeList, $argType;
	$argId++;
    }
    $sig .= "(". join(", ",@argTypeList) .")";
    $sig .= " const" if $method->{Flags} =~ "c";
    return $sig;
}

# Same as methodSignature, but uses the unresolved arguments as found in
# the original method declaration
sub slotSignature($$) {
    my $method = shift;
    my $last = shift;
    my $sig = $method->{astNodeName};
    my @argTypeList;
    my $argId = 0;
    foreach my $arg ( @{$method->{ParamList}} ) {
	last if $argId > $last;
	push @argTypeList, $arg->{NormalizedArgType};
	$argId++;
    }
    $sig .= "(". join(", ",@argTypeList) .")";
    return $sig;
}

# Return the string containing the signature for this method (without return type).
# If the 2nd arg is not the size of $m->{ParamList}, this method returns a
# partial signature (this is used to handle default values).
sub mungedSignature($$) {
    my $method = shift;
    my $last = shift;
#    my $sig = $method->{astNodeName};
    my $sig = "";
    my $argId = 0;
    foreach my $arg ( @{$method->{ParamList}} ) {
		last if $argId > $last;
		$sig .= mungedArgType($method, $arg->{ArgType});
		$argId++;
    }
    return $sig;
}

# Return the string containing the csharp signature for this method (without return type).
# If the 2nd arg is not the size of $m->{ParamList}, this method returns a
# partial signature (this is used to handle default values).
sub csharpMethodSignature($$) {
    my $method = shift;
    my $last = shift;
    my $sig = $method->{astNodeName};
    my @argTypeList;
    my $argId = 0;
    foreach my $arg ( @{$method->{ParamList}} ) {
	$argId++;
	last if $argId > $last;
	push @argTypeList, cplusplusToCSharp( $arg->{ArgType} );
    }
    $sig .= "(". join(", ",@argTypeList) .")";
    return $sig;
}

sub smokeInvocation($$$$$$) {
	my ( $target, $argtypes, $returnType, $mungedMethod, $signature, $addImport ) = @_;

	my $methodCode = "            ";
	if ($returnType ne 'void') {
		$methodCode .= "return ($returnType) ";
	}

	$methodCode .= "$target.Invoke(\"$mungedMethod\", \"$signature\", typeof($returnType)";

	my $arglist = "";
	foreach my $arg ( @{$argtypes} ) {
        $arg =~ /^(ref )?(.*)\s(.*)$/;
		if ($1 ne '') {
			return smokeRefInvocation($target, $argtypes, $returnType, $mungedMethod, $signature, $addImport);
		}
        $arglist .= ", typeof($2), $3";
	}

	return $methodCode . $arglist  . ");\n";
}

sub smokeRefInvocation($$$$$$) {
	my ( $target, $argtypes, $returnType, $mungedMethod, $signature, $addImport ) = @_;

	my $preMethodCode = "";
	my $methodCode = "";
	my $postMethodCode = "";

   $preMethodCode = "            StackItem[] stack = new StackItem[" . (scalar(@{$argtypes}) + 1) . "];\n";
   $methodCode .= "            $target.Invoke(\"$mungedMethod\", \"$signature\", stack);\n";

	my $arglist = "";
	my $argNo = 1;
	foreach my $arg ( @{$argtypes} ) {
        $arg =~ /^(ref )?(.*)\s(.*)$/;
		my $argtype = $2;
		my $argname = $3;

		if ($1 ne '') {
			$preMethodCode .= "            stack[$argNo].s_$argtype = $argname;\n";
			$postMethodCode .= "            $argname = stack[$argNo].s_$argtype;\n";
		} elsif ($argtype =~ /^int$|^uint$|^bool$|^double$|^float$|^long$|^ulong$|^short$|^ushort$/ ) {
			$preMethodCode .= "            stack[$argNo].s_$argtype = $argname;\n";
		} elsif ($argtype =~ /\./ ) {
			$preMethodCode .= "            stack[$argNo].s_int = (int) $argname;\n";
		} else {
			$addImport->{"System.Runtime.InteropServices"} = 1;
			$preMethodCode .= "#if DEBUG\n";
			$preMethodCode .= "            stack[$argNo].s_class = (IntPtr) DebugGCHandle.Alloc($argname);\n";
			$preMethodCode .= "#else\n";
			$preMethodCode .= "            stack[$argNo].s_class = (IntPtr) GCHandle.Alloc($argname);\n";
			$preMethodCode .= "#endif\n";

			$postMethodCode .= "#if DEBUG\n";
			$postMethodCode .= "            DebugGCHandle.Free((GCHandle) stack[$argNo].s_class);\n";
			$postMethodCode .= "#else\n";
			$postMethodCode .= "            ((GCHandle) stack[$argNo].s_class).Free();\n";
			$postMethodCode .= "#endif\n";
		}

		$argNo++;
#        $arglist .= ", typeof($2), $3";
	}

	if ($returnType eq 'void' ) {
		$postMethodCode .= "            return;\n";
	} elsif ($returnType =~ /^int$|^uint$|^bool$|^double$|^float$|^long$|^ulong$|^short$|^ushort$/ ) {
		$postMethodCode .= "            return stack[0].s_$returnType;\n";
	} elsif ($returnType =~ /\./ ) {
		$postMethodCode .= "            return ($returnType) Enum.ToObject(typeof($returnType), stack[0].s_int);\n";
	} else {
		$addImport->{"System.Runtime.InteropServices"} = 1;
		$postMethodCode .= "            object returnValue = ((GCHandle) stack[0].s_class).Target;\n";

		$postMethodCode .= "#if DEBUG\n";
		$postMethodCode .= "            DebugGCHandle.Free((GCHandle) stack[0].s_class);\n";
		$postMethodCode .= "#else\n";
		$postMethodCode .= "            ((GCHandle) stack[0].s_class).Free();\n";
		$postMethodCode .= "#endif\n";

		$postMethodCode .= "            return ($returnType) returnValue;\n";
	}

	return $preMethodCode . $methodCode . $postMethodCode;
}

sub smokeInvocationArgList($) {
	my $argtypes = shift;

	my $arglist = "";
	foreach my $arg ( @{$argtypes} ) {
        if ( $arg =~ /^(ref )?(.*)\s(.*)$/ ) {
        	$arglist .= ", typeof($2), $3";
		}
	}
	return $arglist;
}

sub coerce_type($$$$) {
    #my $m = shift;
    my $union = shift;
    my $var = shift;
    my $type = shift;
    my $new = shift; # 1 if this is a return value, 0 for a normal param

    my $typeEntry = findTypeEntry( $type );
    my $realType = $typeEntry->{realType};

    my $unionfield = $typeEntry->{typeId};
#    die "$type" unless defined( $unionfield );
	if ( ! defined( $unionfield ) ) {
		print STDERR "type field not defined: $type\n";
		return "";
	}
	
    $unionfield =~ s/t_/s_/;

    $type =~ s/\s+const$//; # for 'char* const'
    $type =~ s/\s+const\s*\*$/\*/; # for 'char* const*'

    my $code = "$union.$unionfield = ";
    if($type =~ /&$/) {
	$code .= "(void*)&$var;\n";
    } elsif($type =~ /\*$/) {
	$code .= "(void*)$var;\n";
    } else {
	if ( $unionfield eq 's_class' 
		or ( $unionfield eq 's_voidp' and $type ne 'void*' )
		or $type eq 'QString' ) { # hack
	    $type =~ s/^const\s+//;
	    if($new) {
	        $code .= "(void*)new $type($var);\n";
	    } else {
	        $code .= "(void*)&$var;\n";
	    }
	} else {
	    $code .= "$var;\n";
	}
    }

    return $code;
}

# Generate the list of args casted to their real type, e.g.
# (QObject*)x[1].s_class,(QEvent*)x[2].s_class,x[3].s_int
sub makeCastedArgList
{
    my @castedList;
    my $i = 1; # The args start at x[1]. x[0] is the return value
    my $arg;
    foreach $arg (@_) {
	my $type = $arg;
	my $cast;

	my $typeEntry = findTypeEntry( $type );
	my $unionfield = $typeEntry->{typeId};
#	die "$type" unless defined( $unionfield );
	if ( ! defined( $unionfield ) ) {
		print STDERR "type field not defined: $type\n";
		return "";
	}
	$unionfield =~ s/t_/s_/;

	$type =~ s/\s+const$//; # for 'char* const'
	$type =~ s/\s+const\s*\*$/\*/; # for 'char* const*'

	my $v .= " arg$i";
	if($type =~ /&$/) {
	    $cast = "*($type *)";
	} elsif($type =~ /\*$/) {
	    $cast = "($type)";
        } elsif($type =~ /\(\*\)\s*\(/) { # function pointer ... (*)(...)
            $cast = "($type)";
	} else {
	    if ( $unionfield eq 's_class'
		or ( $unionfield eq 's_voidp' and $type ne 'void*' )
		or $type eq 'QString' ) { # hack
	        $cast = "*($type *)";
	    } else {
	        $cast = "($type)";
	    }
	}
	push @castedList, "$type$v";
	$i++;
    }
    return @castedList;
}


# Adds the import for node $1 to be imported in $2 if not already there
# Prints out debug stuff if $3
sub addImportForClass($$$)
{
    my ( $node, $addImport, $debugMe ) = @_;
    my $importname = csharpImport( $node->{astNodeName} );
#	print "  Importing $importname for node name: " . $node->{astNodeName} . "\n";
	# No import needed, so return
    return if ( $importname eq '' );
    unless ( defined $addImport->{$importname} ) {
	print "  Importing $importname\n" if ($debugMe);
	$addImport->{$importname} = 1;
    }
    else { print "  $importname already imported.\n" if ($debugMe); }
}

sub checkImportsForObject($$$)
{
    my $type = shift;
    my $addImport = shift;
	my $classNode;
	if ($type eq '') {
		return;
	}

	$type = kalyptusDataDict::resolveType($type, $classNode, $rootnode);
	my $csharptype = cplusplusToCSharp($type);
	if ( $csharptype eq 'ArrayList' ) {
		$addImport->{"System.Collections"} = 1;
	} elsif ( $csharptype =~ /^List</ ) {
		$addImport->{"System.Collections.Generic"} = 1;
	} elsif ( $csharptype =~ /^Dictionary</ ) {
		$addImport->{"System.Collections.Generic"} = 1;
	} elsif ( $csharptype =~ /StringBuilder/ ) {
		$addImport->{"System.Text"} = 1;
	} 
}

sub mungedArgType($$) {
    my $method = shift;
    my $arg = shift;

#    my $arg = $method->{ParamList}[$idx]->{ArgType};

    my $typeEntry = findTypeEntry( $arg );
    my $realType = $typeEntry->{realType};

    # A scalar ?
    $arg =~ s/\bconst\b//g;
    $arg =~ s/\s+//g;
#print($method->{astNodeName} . " realType: " . $realType  . " arg: $arg\n");

    if($typeEntry->{isEnum} || $allTypes{$realType}{isEnum} || exists $typeunion{$realType} || exists $mungedTypeMap{$arg})
    {
		my $id = '$'; # a 'scalar
		$id = '?' if $arg =~ /[*&]{2}/;
		$id = $mungedTypeMap{$arg} if exists $mungedTypeMap{$arg};
		return $id;
    }

    # A class ?
    if(exists $new_classidx{$realType}) {
		return '#';
    }

    # A non-scalar (reference to array or hash, undef)
    return '?';
}

sub generateMethod($$$$$$$$$)
{
    my( $virtualMethods, $overridenMethods, $classNode, $m, $addImport, $ancestorCount, $csharpMethods, $mainClassNode, $generateConstructors ) = @_;	# input
    my $methodCode = '';	# output
    my $staticMethodCode = '';	# output
    my $interfaceCode = '';	# output
    my $proxyInterfaceCode = '';	# output
    my $signalCode = '';	# output
    my $notConverted = '';	# output
	
    my $name = $m->{astNodeName}; # method name
    
	my @heritage = kdocAstUtil::heritage($classNode);
    my $className  = join( "::", @heritage );
    
	@heritage = kdocAstUtil::heritage($mainClassNode);
	my $mainClassName  = join( "::", @heritage );

	# The csharpClassName might be 'QWidget', while currentClassName is 'QRangeControl'
	# and the QRangeControl methods are being copied into QWidget.    
	my $csharpClassName  = $mainClassNode->{astNodeName};
    my $currentClassName  = $classNode->{astNodeName};
	
	my $firstUnknownArgType = 99;
    my $returnType = $m->{ReturnType};

    # Don't use $className here, it's never the fully qualified (A::B) name for a ctor.
    my $isConstructor = ($name eq $classNode->{astNodeName} );
    my $isDestructor = ($returnType eq '~');

	my $isStatic = $m->{Flags} =~ "s" || $classNode->{NodeType} eq 'namespace';
	my $isPure = $m->{Flags} =~ "p";
	my $fullSignature = methodSignature( $m, $#{$m->{ParamList}} );

    # Don't generate anything for destructors, or constructors for namespaces
    return if $isDestructor 
			or ($classNode->{NodeType} eq 'namespace' and $isConstructor)
			or $m->{Flags} =~ "="
#			or (!$mainClassNode->{CanBeInstanciated} and $m->{Access} =~ /protected/)
			or $name =~ /^operator\s*(=|(\[\])|([|&^+-]=)|(!=))\s*$/
			or (!$isStatic and $name =~ /^operator\s*((\+\+)|(--))$/ and $#{$m->{ParamList}} == 0)
			or ($name =~ /^operator\s*\*$/ and $#{$m->{ParamList}} == -1);

	my $item = kdocAstUtil::findRef( $classNode, "Q_PROPERTY_" . $name );
	if ( defined $item 
			&& $item->{NodeType} eq 'property' 
			&& ! $isStatic 
			&& $#{$m->{ParamList}} == -1 
			&& $m->{Flags} !~ 'v'
			&& $m->{Access} !~ /slots|signals/) {
        # If there is a property with the same name, don't bother
		return;
	}
    my $propertyName = $name;
    if ( @{$m->{ParamList}} == 1 && $propertyName =~ /^set(.)(.*)/ ) {
		$propertyName = "Q_PROPERTY_" . lc($1) . $2;
		$item = kdocAstUtil::findRef( $classNode, $propertyName );
		if (	defined $item 
				&& $item->{NodeType} eq 'property' 
				&& ! $isStatic 
				&& $m->{Flags} !~ 'v'
				&& $m->{Access} !~ /slots|signals/ ) 
		{
        	# If there is a property with the same name, don't bother
			return;
		}
	}

	if ($classNode->{astNodeName} eq $main::globalSpaceClassName) {
		my $sourcename = $m->{Source}->{astNodeName};
		# Only put Global methods which came from sources beginning with q into class Qt
		if ($csharpClassName eq 'Qt' and ( $sourcename !~ /\/q[^\/]*$/ or $sourcename =~ /string.h$/ or $sourcename =~ /qwt/ )) {
			return;
		}
		# ..and any other global methods into KDE
		if ($csharpClassName eq 'KDE' and $m->{Source}->{astNodeName} =~ /\/q[^\/]*$/) {
			return;
		}

		if ( $sourcename !~ s!.*(kio/|kparts/|dom/|kabc/|ksettings/|kjs/|ktexteditor/|kdeprint/|kdesu/)(.*)!$1$2!m ) {
			$sourcename =~ s!.*/(.*)!$1!m;
		}
		if ( $sourcename eq '' ) {
			return;
		}
	}
	
    if ($returnType eq 'void') {
    	$returnType = undef;
	} else {
	    # Detect objects returned by value
    	checkImportsForObject( $returnType, $addImport, $classNode );
	}
	
	my $hasDuplicateSignature = 0;
	
    return if ( $m->{SkipFromSwitch} && $m->{Flags} !~ "p" ); 

    my $argId = 0;

    my @argTypeList=();
    my @csharpArgTypeList=();
    my @csharpArgTypeOnlyList = ();
	
    foreach my $arg ( @{$m->{ParamList}} ) {
		$argId++;
	
		if ( $arg->{ArgName} =~ /^ref$|^super$|^int$|^params$|^env$|^cls$|^obj$|^byte$|^event$|^base$|^object$|^in$|^out$|^checked$|^delegate$|^string$|^interface$|^override$|^lock$/ ) {
			$arg->{ArgName} = "";
		}

		if ( $arg->{ArgName} =~ /^short$|^long$/ ) {
			# Oops looks like a parser error
			$arg->{ArgType} = $arg->{ArgName};
			$arg->{ArgName} = "";
		}
	
	print STDERR "  Param ".$arg->{astNodeName}." type: ".$arg->{ArgType}." name:".$arg->{ArgName}." default: ".$arg->{DefaultValue}." csharp: ".cplusplusToCSharp($arg->{ArgType})."\n" if ($debug);
		
	my $argType = $arg->{ArgType};
	my $csharpArgType;
	my $csharpArg;
	my $argName;
	
	if ( cplusplusToCSharp($argType) eq "" && $firstUnknownArgType > $argId ) {
		$firstUnknownArgType = $argId;
	}
	
	$csharpArg = ($arg->{ArgName} eq "" ? "arg" . $argId : $arg->{ArgName});
	$csharpArgType = cplusplusToCSharp($argType);

#	if ( $csharpArgType =~ /StringBuilder/ && $classNode->{astNodeName} ne $main::globalSpaceClassName) {
#		$addImport->{"System.Text"} = 1;
#	}
	if ( $classNode->{astNodeName} eq 'Qt' or $classNode->{astNodeName} eq 'KDE' ) {
		$addImport->{"System.Collections.Generic"} = 1;
	}

	push @argTypeList, $argType;
	push @csharpArgTypeOnlyList, $csharpArgType;
	push @csharpArgTypeList, $csharpArgType  . " " . $csharpArg;
	
	# Detect objects passed by value
	if ($classNode->{astNodeName} ne $main::globalSpaceClassName) {
		checkImportsForObject( $argType, $addImport, $classNode );
	}
    }

	if ( $name eq 'QApplication' or ($csharpClassName eq 'KCmdLineArgs' and $name eq 'init' and scalar(@csharpArgTypeList) > 1) ) {
		# Junk the 'int argc' parameter
		shift @csharpArgTypeList;
		shift @csharpArgTypeOnlyList;
	}

    my @castedArgList = makeCastedArgList( @argTypeList );

    # We iterate as many times as we have default params
    my $firstDefaultParam = $m->{FirstDefaultParam};
    $firstDefaultParam = scalar(@argTypeList) unless defined $firstDefaultParam;
    my $iterationCount = scalar(@argTypeList) - $firstDefaultParam;
	
	my $csharpReturnType = cplusplusToCSharp($m->{ReturnType});
	$csharpReturnType =~ s/^(out) |(ref) //;
	$csharpReturnType =~ s/StringBuilder/string/;
	
	if ($m->{ReturnType} =~ /^int\&/) {
		$csharpReturnType = 'int';
	}
	
	if ($csharpReturnType eq "") {
		$firstUnknownArgType = 0;
	}

    print STDERR "  ". ($iterationCount+1). " iterations for $name\n" if ($debug);
	
	my $csharpSignature = csharpMethodSignature( $m, @argTypeList );
	
	if ( defined $csharpMethods->{$csharpSignature} ) {
		$hasDuplicateSignature = 1;
	}
	
	my $docnode = $m->{DocNode};
	if ( $firstUnknownArgType >= 0 && $m->{Access} !~ /signals/ && ! $hasDuplicateSignature
		&& $classNode->{astNodeName} ne $main::globalSpaceClassName
		&& defined $docnode && ($generateConstructors || !$isConstructor) ) 
	{
		my $csharpdocComment = printCSharpdocComment( $docnode, "", "        /// ", "" );
		if ($isStatic) {
			$staticMethodCode .=  $csharpdocComment unless $csharpdocComment =~ /^\s*$/;
		} else {
			$methodCode .=  $csharpdocComment unless $csharpdocComment =~ /^\s*$/;
		}
	}

    while($iterationCount >= 0) {
	
	$csharpMethods->{$csharpSignature} = 1;

	local($") = ",";
	my $argsSignature = argsSignature( $m, $#argTypeList );
	my $signature = methodSignature( $m, $#argTypeList );
	my $slotSignature = slotSignature( $m, $#argTypeList );
	my $mungedSignature = mungedSignature( $m, $#argTypeList );
	my $mungedMethod = $m->{astNodeName} . $mungedSignature;
	my $csharpparams = join( ", ", @csharpArgTypeList );
	
	# Ignore any methods in QGlobalSpace except those that are operator methods
	# with at least one arg that is the type of the current class
	if (	$classNode->{astNodeName} eq $main::globalSpaceClassName
			&& $csharpClassName ne 'Qt'
			&& $csharpClassName ne 'KDE'
			&& !(	$name =~ /^operator.*/ 
					&& $name ne 'operator<<' 
					&& $name ne 'operator>>'
					&& $csharpparams =~ /$csharpClassName / ) ) 
	{
		;
	} elsif ($firstUnknownArgType <= scalar(@argTypeList) || $hasDuplicateSignature || ($name =~ /^qObject$/) || $m->{Access} =~ /dcop/ || $name =~ ?[|&*/+^-]=? ) {
		if ( $firstUnknownArgType <= scalar(@argTypeList) || $m->{Access} =~ /dcop/  || $name =~ ?[|&*/+^-]=? ) {
			my $failedConversion = "        // " . $m->{ReturnType} . " $name(@castedArgList[0..$#argTypeList]); >>>> NOT CONVERTED\n";
			if ( $m->{Access} =~ /signals/ ) {
				$signalCode .= $failedConversion;
			} else {
				$notConverted .= $failedConversion;
			}
		}
	} else {

		if ( $csharpReturnType =~ s/string\[\]/ArrayList/ ) {
			$addImport->{"System.Collections"} = 1;
		}

		if ( $csharpReturnType =~ s/string\[\]/List<string>/ ) {
			$addImport->{"System.Collections.Generic"} = 1;
		}
	    
		my $cplusplusparams;
		my $i = 0;
		for my $arg (@argTypeList) {
			$cplusplusparams .= "," if $i++;
			$cplusplusparams .= "arg" . $i;
		}

		my $access = $m->{Access};
		$access =~ s/_slots//;

		if ($isConstructor) {
			if ( $generateConstructors ) {
#				$proxyInterfaceCode .= "            void new$csharpClassName($csharpparams);\n";
				$methodCode .= "        public $csharpClassName($csharpparams) : this((Type) null) {\n";
				$methodCode .= "            CreateProxy();\n";
				$methodCode .= smokeInvocation("interceptor", \@csharpArgTypeList, "void", $mungedMethod, $signature, $addImport);
				$methodCode .= "        }\n";
			}
		} elsif ( $mainClassNode->{Pure} && $isPure ) {
			if ( $#argTypeList == $#{$m->{ParamList}} ) {
				if ($name =~ /^sizeHint$/) {
					# This method is public in some places, but protected in others,
					# so make them all public.
					$access = "public";
				}

				if ($name =~ /^([a-z])(.*)/) {
					$name = uc($1) . $2;
				}
				
				if ($access eq 'public' && ! $isStatic) {
					$interfaceCode .= "        $csharpReturnType $name($csharpparams);\n";
				}
	
				# Only change the method name to start with an upper case letter
				# if it doesn't clash with an enum with the same name
				my $item = kdocAstUtil::findRef( $classNode, $name );
				if ( defined $item && $item->{NodeType} eq 'enum' && $name =~ /^([A-Z])(.*)/) {
					$name = lc($1) . $2;
				}

				$methodCode .= "        \[SmokeMethod(\"$signature\")]\n";

				if (	defined $virtualMethods->{$fullSignature}{method}
						|| defined $overridenMethods->{$signature}{method}
						|| (defined $overridenMethods->{$name}{method}) )
				{
					if ($csharpClassName eq 'QLayout' && $name eq 'SetGeometry') {
						$methodCode .= "        " . $access . " abstract ";
					} else {
						$methodCode .= "        " . $access . " new abstract ";
					}
				} else {
					$methodCode .= "        " . $access . " abstract ";
				}

				$methodCode .= $csharpReturnType;
				$methodCode .= " $name($csharpparams);\n";
			}
		} elsif ( $name =~ /^operator.*/ && $name ne 'operator<<' && $name ne 'operator>>') {
			$name =~ s/ //;
			$name =~ s!([|&*/+^-])=!$1!;
			if ( $csharpSignature =~ s!([|&*/+^-])=!$1! ) {
				if ( $csharpMethods->{$csharpSignature} ) {
					print("dup method found: $csharpSignature\n");
				}
				$csharpMethods->{$csharpSignature} = 1;
			}
			if (!$isStatic) {
				# In C# operator methods must be static, so if the C++ version isn't 
				# static, then add another arg 'lhs', the value of 'this'.
	    		$csharpparams = "$csharpClassName lhs" . ($csharpparams eq "" ? "" : ", ") . $csharpparams;
				unshift @csharpArgTypeList, "$csharpClassName lhs";
				unshift @csharpArgTypeOnlyList, $csharpClassName;
				$csharpSignature =~ s/\(/($csharpClassName, /;
				$csharpSignature =~ s/, \)/)/;
				if ( $csharpMethods->{$csharpSignature} ) {
					print("dup method found: $csharpSignature\n");
				}
				$csharpMethods->{$csharpSignature} = 1;
			}

			if ( $classNode->{astNodeName} ne $main::globalSpaceClassName
				|| (@csharpArgTypeOnlyList[0] eq $csharpClassName || @csharpArgTypeOnlyList[1] eq $csharpClassName) )
			{
				$proxyInterfaceCode .= "            $csharpReturnType $operatorNames{$name}($csharpparams);\n";
	    		
				$staticMethodCode .= "        " . $access . " static ";
				$staticMethodCode .= $csharpReturnType;

	    		$staticMethodCode .= " $name($csharpparams) \{\n";
	    		$staticMethodCode .= smokeInvocation("staticInterceptor", \@csharpArgTypeList, $csharpReturnType, $mungedMethod, $signature, $addImport);
		    	$staticMethodCode .= "        }\n";
			}
	    		
			if (	$name =~ /operator==/ 
					&& ( @csharpArgTypeOnlyList[0] eq $csharpClassName || @csharpArgTypeOnlyList[1] eq $csharpClassName )
					&& $csharpClassName ne 'Qt' 
					&& $csharpClassName ne 'KDE' )
			{
				# Add a 'operator!=' method defined in terms of 'operator=='
				$staticMethodCode .= "        " . $access . " static bool";
	    		$staticMethodCode .= " operator!=($csharpparams) \{\n";
	    		
				$staticMethodCode .= "            return ";
	    		$staticMethodCode .= "!(bool) staticInterceptor.Invoke(\"$mungedMethod\", \"$signature\", typeof($csharpReturnType)". smokeInvocationArgList(\@csharpArgTypeList) . ");\n";
		    	$staticMethodCode .= "        }\n";

				if (!defined $mainClassNode->{HasEquals}) {
					$methodCode .= "        public override bool Equals(object o) \{\n";
					$methodCode .= "            if (!(o is $csharpClassName)) { return false; }\n";
					
					$methodCode .= "            return this == ($csharpClassName) o;\n";
					$methodCode .= "        }\n";
					
					$methodCode .= "        public override int GetHashCode() \{\n";
					$methodCode .= "            return interceptor.GetHashCode();\n";
					$methodCode .= "        }\n";
                    $mainClassNode->{HasEquals} = 1;
				}
			}

			if (	$name =~ /^operator\s*<$/ 
					&& $classNode->{astNodeName} ne $main::globalSpaceClassName )
			{
				my $item = kdocAstUtil::findRef( $classNode, "operator>" );
				if (! defined $item || $item->{Parent}->{astNodeName} eq 'Global') {
					$staticMethodCode .= "        " . $access . " static bool";
					$staticMethodCode .= " operator>($csharpparams) \{\n";
					
					$staticMethodCode .= "            return ";
					$staticMethodCode .= "!(bool) staticInterceptor.Invoke(\"$mungedMethod\", \"$signature\", typeof($csharpReturnType)". smokeInvocationArgList(\@csharpArgTypeList) . ")\n";
					$staticMethodCode .= "                        && !(bool) staticInterceptor.Invoke(\"operator==$mungedSignature\", \"operator==$argsSignature\", typeof($csharpReturnType)". smokeInvocationArgList(\@csharpArgTypeList) . ");\n";
					$staticMethodCode .= "        }\n";
				}
			}
	    } else {
			if ( $access eq 'public' or $access eq 'protected' ) {
				if (	($csharpClassName eq 'QHeaderView' && $name =~ /^scrollTo$|^indexAt$|^visualRect$/)
						|| ($csharpClassName eq 'QSvgGenerator' && $name =~ /^paintEngine$/)
						|| ($csharpClassName eq 'QGridLayout' && $name =~ /^addItem$/) 
						|| ($csharpClassName eq 'QGraphicsWidget' && $name =~ /^updateGeometry$/) 
						|| $name =~ /^sizeHint$/ )
				{
					# These methods are public in some places, but protected in others,
					# so make them all public.
					$access = "public";
				}

				if ($name eq 'operator<<' || $name eq 'operator>>') {
					# 'operator<<' and 'operator>>' can only have int types as the second
					# arg in C#, so convert them to op_read() and op_write() calls
					$name = $operatorNames{$name}
				} elsif ($name =~ /^([a-z])(.*)/) {
					if ($name ne 'type') {
						$name = uc($1) . $2;
					}

					# Only constructors can have the same name as the class
					if ( $name eq $csharpClassName || $name eq 'Transition' ) {
						$name = lc($1) . $2;
					}

					# Only change the method name to start with an upper case letter
					# if it doesn't clash with an enum with the same name
					my $item = kdocAstUtil::findRef( $classNode, $name );
					if ( defined $item && $item->{NodeType} eq 'enum' && $name =~ /^([A-Z])(.*)/) {
						$name = lc($1) . $2;
					}

					$item = kdocAstUtil::findRef( $classNode, "Q_PROPERTY_" . $m->{astNodeName} );
					if ( defined $item && $item->{NodeType} eq 'property' ) {
        				# If there is a property with the same name, start with lower case 
						$name = lc($1) . $2;
					}

					if ($classNode->{astNodeName} eq 'QIODevice' and $name eq 'State') {
						$name = 'state';
					}
				}
				
				if ($access eq 'public' && ! $isStatic) {
	    			$interfaceCode .= "        $csharpReturnType $name($csharpparams);\n";
				}
					
				if (($isStatic or $classNode->{NodeType} eq 'namespace')) {
	    			$proxyInterfaceCode .= "            $csharpReturnType $name($csharpparams);\n";
				}

				if ( $m->{Access} =~ /_slots/ && !$isStatic )  {
					$methodCode .= "        [Q_SLOT(\"". $m->{ReturnType} . " $slotSignature" . "\")]\n";
				}

				my $overridenVirtualMethod = $virtualMethods->{$signature}{method};
				$virtualMethods->{$signature}{method} = undef;
				my $overridenMethod = $overridenMethods->{$signature}{method};

                if (defined $overridenVirtualMethod || $m->{Flags} =~ "v") {
					$methodCode .= "        \[SmokeMethod(\"$signature\")]\n";
				}

				if ($isStatic or $classNode->{NodeType} eq 'namespace') {
					$staticMethodCode .= "        $access static ";
				} else {
					$methodCode .= "        $access ";		
				}
	
				if (	($name eq 'ToString' && $csharpparams eq '')
						|| (	($csharpClassName =~ /^QGraphicsSvgItem$|^QGraphicsTextItem$/)
								&& ($name eq 'Children' || $name eq 'InputMethodQuery') ) )
				{
					# Tricky. QGraphicsSvgItem and QGraphicsTextItem inherit a 'children()' method from both
					# of their parents, and so is it resolved on the return type in C++?
					$methodCode .= "new ";
				} elsif ( defined $overridenVirtualMethod ) {
					# Only change the method name to start with an upper case letter
					# if it doesn't clash with an enum with the same name
					my $overrideClass = $virtualMethods->{$fullSignature}{class};

					# Special case looking for QStyle name clashes with methods/enums
					if ($csharpClassName =~ /Style/) {
						$overrideClass = kdocAstUtil::findRef( $rootnode, "QStyle" );
					}

					my $item = kdocAstUtil::findRef( $overrideClass, $name );
					if ( defined $item && $item->{NodeType} eq 'enum' && $name =~ /^([A-Z])(.*)/) {
						$name = lc($1) . $2;
					}

					$item = kdocAstUtil::findRef( $overrideClass, "Q_PROPERTY_" . $m->{astNodeName} );
					if ( defined $item && $item->{NodeType} eq 'property' ) {
        				# If there is a property with the same name, start with lower case 
						$name = lc($1) . $2;
					}

					if (	$overridenVirtualMethod->{Flags} !~ "p"
							&& (	($overridenVirtualMethod->{Access} =~ /public/ && $m->{Access} =~ /protected/)
									|| ($overridenVirtualMethod->{Access} =~ /protected/ && $m->{Access} =~ /public/) ) ) 
					{
						$methodCode .= "new virtual ";
					} elsif (	!defined $overridenVirtualMethod->{FirstDefaultParam} 
							&& $#argTypeList < $#{$overridenVirtualMethod->{ParamList}} )
					{
						;
					} elsif (	defined $overridenVirtualMethod->{FirstDefaultParam} 
								&& $overridenVirtualMethod->{Flags} =~ "p"
								&& $#argTypeList < $#{$overridenVirtualMethod->{ParamList}} )
					{
						$methodCode .= "virtual ";
					} elsif ( $csharpClassName eq 'QAbstractListModel' && $name eq 'Index' && $#argTypeList == 0) {
						;
					} elsif (	$ancestorCount == 0
								|| (	$ancestorCount > 1
										&& defined $interfacemap{$overridenVirtualMethod->{Parent}->{astNodeName}} ) )
					{
						$methodCode .= "virtual ";
					} elsif ($overridenVirtualMethod->{Flags} =~ "p") {
						$methodCode .= "override ";
					} else {
 						$methodCode .= "override ";
					}
				} elsif ($m->{Flags} =~ "v") {
					if (defined $overridenMethods->{$name}{method}) {
						$methodCode .= "new virtual ";
					} else {
						$methodCode .= "virtual ";
					}
				} elsif ( defined $overridenMethod ) {
					if ( $isStatic ) {
						$staticMethodCode .= "new ";
					} elsif (	$ancestorCount == 1 
								|| !defined $interfacemap{$overridenMethod->{Parent}->{astNodeName}} ) 
					{
						$methodCode .= "new ";
					}
				} elsif ( defined $overridenMethods->{$name}{method} ) {
					$methodCode .= "new ";
				}

				if (	$name eq 'Exec' 
						&& ($csharpClassName eq 'QApplication' || $csharpClassName eq 'QCoreApplication') ) 
				{
					$staticMethodCode .= $csharpReturnType;
	    			$staticMethodCode .= " $name($csharpparams) \{\n";
    				$staticMethodCode .= "            int result = (int) staticInterceptor.Invoke(\"exec\", \"exec()\", typeof(int));\n";
    				$staticMethodCode .= "            Qyoto.SetApplicationTerminated();\n";
    				$staticMethodCode .= "            return result;\n";
		    		$staticMethodCode .= "        }\n";
				} elsif ($isStatic or $classNode->{NodeType} eq 'namespace') {
					$staticMethodCode .= $csharpReturnType;
	    			$staticMethodCode .= " $name($csharpparams) \{\n";
	    			$staticMethodCode .= smokeInvocation("staticInterceptor", \@csharpArgTypeList, $csharpReturnType, $mungedMethod, $signature, $addImport);
		    		$staticMethodCode .= "        }\n";
				} else {
					$methodCode .= $csharpReturnType;
	    			$methodCode .= " $name($csharpparams) \{\n";
	    			$methodCode .= smokeInvocation("interceptor", \@csharpArgTypeList, $csharpReturnType, $mungedMethod, $signature, $addImport);
		    		$methodCode .= "        }\n";
				}
			} else {
				if ( $access =~ /signals/ )  {
					if ($name =~ /^([a-z])(.*)/) {
						$name = uc($1) . $2;
					}
					my $docnode = $m->{DocNode};
					if ( defined $docnode ) {
						my $csharpdocComment = printCSharpdocComment( $docnode, "", "        /// ", "" );
						$signalCode .=  $csharpdocComment unless $csharpdocComment =~ /^\s*$/;
					}
					$signalCode .= "        [Q_SIGNAL(\"" . $m->{ReturnType} . " $slotSignature" . "\")]\n";
	    			$signalCode .= "        void $name($csharpparams);\n";
				}
			}
	    }
    }

	pop @argTypeList;
	pop @csharpArgTypeList;
	pop @csharpArgTypeOnlyList;
	
	$csharpSignature = csharpMethodSignature( $m, @argTypeList );
	$hasDuplicateSignature = (defined $csharpMethods->{$csharpSignature} ? 1 : 0);
	
	$methodNumber++;
	$iterationCount--;
    } # Iteration loop

    return ( $methodCode, $staticMethodCode, $interfaceCode, $proxyInterfaceCode, $signalCode, $notConverted );
}

sub resolveEnumValue($$)
{
	my ( $enumClass, $enumValue ) = @_;

	my $classNode = kdocAstUtil::findRef( $rootnode, $enumClass );
	my $enumType;

    Iter::MembersByType ( $classNode, undef,
		sub {	my ($classNode, $enumNode ) = @_;
				
				if ( $enumNode->{NodeType} eq 'enum' ) {
					my @enums = split(",", $enumNode->{Params});
					foreach my $enum ( @enums ) {
						if ($enum =~ /^\s*(\w+)/) {
							if ($1 eq $enumValue) {
								$enumType = $enumNode->{astNodeName};
							}
						}
					}
				}
		}, undef );

	if (defined $enumType) {
        $enumType =~ s/^Type$/TypeOf/;
		return "$enumClass.$enumType.$enumValue";
	} else {
		return "$enumClass.$enumValue";
	}
}

sub generateEnum($$$)
{
    my( $classNode, $m, $generateAnonymous ) = @_;	# input
    my $methodCode = '';	# output

    my @heritage = kdocAstUtil::heritage($classNode);
    my $className  = join( "::", @heritage );
    my $csharpClassName  = $classNode->{astNodeName};

	if ( ($generateAnonymous and $m->{astNodeName} ) or (! $generateAnonymous and ! $m->{astNodeName}) ) {
		return;
	}
	
	if ( defined $m->{DocNode} ) {
		my $csharpdocComment = printCSharpdocComment( $m->{DocNode}, "", "    /// ", "" );
		$methodCode .=  $csharpdocComment unless $csharpdocComment =~ /^\s*$/;
	}
	
	# In C# enums must have names, so anonymous C++ enums become constants
	if (! $m->{astNodeName}) {
		return generateConst($classNode, $m, $generateAnonymous);
	}
	
	$m->{astNodeName} =~ /(.)(.*)/;

#	my $item = kdocAstUtil::findRef( $classNode, lc($1) . $2 );
	if ( $m->{astNodeName} eq 'Type') {
		# Enums and capitalized method names share the same namespace in C#, so add
		# 'E_' to the front to avoid a clash.
		$methodCode .= "    public enum TypeOf {\n";
	} else {
		$methodCode .= "    public enum " . $m->{astNodeName} . " {\n";
	}
	
	my @enums = split(",", $m->{Params});
	my $enumCount = 0;
	foreach my $enum ( @enums ) {

		if ($enum =~ /.*\s(\w*)::(\w*)/) {
			my $result = resolveEnumValue($1, $2);
			$enum =~ /(.*\s)(\w*)::(\w*)(.*)/;
			if ( $className eq 'KProtocolInfo::ExtraField' && $m->{astNodeName} eq 'Type' ) {
				$enum = $1 . "(int) " . $result . $4;
			} else {
				$enum = $1 . $result . $4;
			}
		}


		if ($m->{astNodeName} ne 'KeyboardModifier') {
			$enum =~ s/KeyboardModifierMask/KeyboardModifier.KeyboardModifierMask/;
		}

		if ($m->{astNodeName} ne 'PolicyFlag') {
			$enum =~ s/GrowFlag/PolicyFlag.GrowFlag/;
			$enum =~ s/ExpandFlag/PolicyFlag.ExpandFlag/;
			$enum =~ s/ShrinkFlag/PolicyFlag.ShrinkFlag/;
			$enum =~ s/IgnoreFlag/PolicyFlag.IgnoreFlag/;
		}

		$enum =~ s/\s//g;
		$enum =~ s/::/./g;
		$enum =~ s/::([a-z])/./g;
		$enum =~ s/\.\././g;
		$enum =~ s/\(mode_t\)//;
		$enum =~ s/internal/_internal/;
		$enum =~ s/fixed/_fixed/;
		$enum =~ s/sizeof\(void\*\)/4/;
		if ( $enum =~ /(.*)=([-0-9]+)$/ ) {
			$methodCode .= "        $1 = $2,\n";
			$enumCount = $2;
			$enumCount++;
		} elsif ( $enum =~ /(.*)=(.*)/ ) {
			my $name = $1;
			my $value = $2;
			$value =~ s/^MAX_INT$/2147483647/;
			$value =~ s/^SO_/QStyleOption.OptionType.SO_/;
			if ($classNode->{astNodeName} eq 'QStyleHintReturn' || $classNode->{astNodeName} eq 'QStyleHintReturnMask') {
				$value =~ s/^SH_/QStyleHintReturn.HintReturnType.SH_/;
			} elsif ($classNode->{astNodeName} eq 'QStyle') {
				$value =~ s/^SH_/QStyle.StyleHint.SH_/;
			}

			$methodCode .= "        $name = $value,\n";
#			if ($value =~ /(0xf0000000)|(0xffffffff)|(0xF0000000)|(0xFFFFFFFF)/) {
			if ($value =~ /(0x[89aAbBcCdDeEfF][a-fA-F0=9][a-fA-F0=9][a-fA-F0=9][a-fA-F0=9][a-fA-F0=9][a-fA-F0=9][a-fA-F0=9])/) {
				$methodCode =~ s/enum ((E_)?[^\s]*)/enum $1 : uint/;
			}
		} else {
			$methodCode .= "        $enum = $enumCount,\n";
			$enumCount++;
		}
	}
		
	$methodCode .= "    }\n";
	$methodNumber++;
		
    return ( $methodCode );
}

sub generateConst($$$)
{
    my( $classNode, $m, $generateAnonymous ) = @_;	# input
    my $methodCode = '';	# output

    my @heritage = kdocAstUtil::heritage($classNode);
    my $className  = join( "::", @heritage );
    my $csharpClassName  = $classNode->{astNodeName};
	
	my @enums = split(",", $m->{Params});
	my $enumCount = 0;
	foreach my $enum ( @enums ) {
		$enum =~ s/\s//g;
		$enum =~ s/::/./g;
		$enum =~ s/\(mode_t\)//;
		$enum =~ s/internal/_internal/;
		$enum =~ s/fixed/_fixed/;
		$enum =~ s/IsActive/_IsActive/;

		if ($enum =~ /(.*)=(0[xX][fF][0-9a-fA-F]{7})$/) {
			$methodCode .= "        public const long $1 = $2;\n";
		} elsif ( $enum =~ /(.*)=([-0-9]+)$/ ) {
			if (	$1 eq 'Type' 
					&& $classNode->{astNodeName} ne 'QGraphicsItem' 
					&& $classNode->{astNodeName} ne 'QGraphicsTextItem' 
					&& $classNode->{astNodeName} ne 'QGraphicsSvgItem' )
  			{
				$methodCode .= "        public new const int $1 = $2;\n";
			} else {
				$methodCode .= "        public const int $1 = $2;\n";
			}
			$enumCount = $2;
			$enumCount++;
		} elsif ( $enum =~ /(.*)=.*static_cast<.*>\((.*)\)/ ) {
			$methodCode .= "        public const int $1 = $2;\n";
		} elsif ( $enum =~ /(.*)=(.*)/ ) {
			my $name = $1;
			my $value = $2;
			if ($value =~ /\s*(\w*)\.(\w*)/) {
				$value = "(int) " . resolveEnumValue($1, $2);
			}

			$value =~ s/^MAX_INT$/2147483647/;
			$methodCode .= "        public const int $name = $value;\n";
		} else {
			$methodCode .= "        public const int $enum = $enumCount;\n";
			$enumCount++;
		}
	}
		
	$methodNumber++;
		
    return ( $methodCode );
}

sub generateVar($$$)
{
    my( $classNode, $m, $addImport ) = @_;	# input
    my $methodCode = '';	# output
    my $interfaceCode = '';	# output
    my $proxyInterfaceCode = '';	# output

    my @heritage = kdocAstUtil::heritage($classNode);
    my $className  = join( "::", @heritage );
    my $csharpClassName  = $classNode->{astNodeName};

    my $name = $m->{astNodeName};
	my $resolvedType = kalyptusDataDict::resolveType($m->{Type}, $classNode, $rootnode);

    my $varType = $resolvedType;
    $varType =~ s/static\s//;
    $varType =~ s/const\s+(.*)\s*&/$1/;
    $varType =~ s/\s*$//;
    my $fullName = "$className\::$name";
	$varType = cplusplusToCSharp($varType);
	if (!defined $varType) {
    	return ( $methodCode, $interfaceCode, $proxyInterfaceCode );
	}

    checkImportsForObject( $m->{Type}, $addImport, $classNode );

    my $propertyName = $name;
	if ( $className eq 'KTextEditor::CodeCompletionModel' && $name eq 'ColumnCount' ) {
		# special case this one, since there's the inherited virtual
		# method QAbstractItemModel::columnCount(), which starts with
		# an uppercase letter in C#
		$propertyName = 'columnCount';
	} elsif ( $propertyName =~ /^([a-z])(.*)/) {
		$propertyName = uc($1) . $2;
	}

	# Only change the method name to start with an upper case letter
	# if it doesn't clash with an enum with the same name
	my $uppercaseItem = kdocAstUtil::findRef( $classNode, $propertyName );
	if (defined $uppercaseItem && $uppercaseItem->{NodeType} eq 'enum' && $propertyName =~ /^([A-Z])(.*)/) {
		$propertyName = lc($1) . $2;
	}

	if ( $m->{Flags} =~ "s" ) {	
    	$methodCode .= "        public static $varType $propertyName() {\n";
    	$methodCode .= "            return ($varType) staticInterceptor.Invoke(\"$name\", \"$name()\", typeof($varType));\n";
    	$methodCode .= "        }\n";
		$proxyInterfaceCode .= "            $varType $name();\n";
	} else {
		$methodCode .= "        public $varType $propertyName {\n";
		$methodCode .= "            get { return ($varType) interceptor.Invoke(\"$name\", \"$name()\", typeof($varType)); }\n";
		my $setMethod = $name;
		if ($setMethod =~ /^(\w)(.*)/) {
			my $ch = $1;
			$ch =~ tr/a-z/A-Z/;
			$setMethod = "set$ch$2";
		}
		$methodCode .= "            set { interceptor.Invoke(\"$setMethod" . mungedArgType($m, $resolvedType) . "\", \"$setMethod($resolvedType)\", typeof(void), typeof($varType), value); }\n";
		$methodCode .= "        }\n";
		$interfaceCode .= "        ". cplusplusToCSharp($varType) . " $name();\n";
	}

    $methodNumber++;
    return ( $methodCode, $interfaceCode, $proxyInterfaceCode );
}

sub generateProperty($$$$)
{
    my( $overridenMethods, $classNode, $m, $addImport ) = @_;	# input
    my $methodCode = '';	# output

    my @heritage = kdocAstUtil::heritage($classNode);
    my $className  = join( "::", @heritage );
    my $csharpClassName  = $classNode->{astNodeName};

    my $name = $m->{astNodeName};

	my $resolvedType = kalyptusDataDict::resolveType($m->{Type}, $classNode, $rootnode);
    my $propertyType = cplusplusToCSharp( $resolvedType );
    if ( ! defined $propertyType ) {
    	return ( $methodCode );
	}

	checkImportsForObject( $m->{Type}, $addImport, $classNode );

    $name =~ s/Q_PROPERTY_//;
    my $propertyName = $name;
	if ( $propertyName =~ /^([a-z])(.*)/ && $propertyName ne 'icon') {
		$propertyName = uc($1) . $2;
	}

	# Only change the method name to start with an upper case letter
	# if it doesn't clash with an enum with the same name
	my $uppercaseItem = kdocAstUtil::findRef( $classNode, $propertyName );
	if (defined $uppercaseItem && $uppercaseItem->{NodeType} eq 'enum' && $propertyName =~ /^([A-Z])(.*)/) {
		$propertyName = lc($1) . $2;
	}

	$methodCode .= "        [Q_PROPERTY(\"$resolvedType\", \"$name\")]\n";

	if ( defined $overridenMethods->{$propertyName}{method} ) {
		$methodCode .= "        public new $propertyType $propertyName {\n";
	} else {
		$methodCode .= "        public $propertyType $propertyName {\n";
	}

	if ( defined $m->{READ} ) {
		$methodCode .= "            get { return ($propertyType) interceptor.Invoke(\"$m->{READ}\", \"$m->{READ}()\", typeof($propertyType)); }\n";
	}

	if ( defined $m->{WRITE} ) {
		$methodCode .= "            set { interceptor.Invoke(\"$m->{WRITE}" . mungedArgType($m, $resolvedType) . "\", \"$m->{WRITE}($resolvedType)\", typeof(void), typeof($propertyType), value); }\n";
	}

	$methodCode .= "        }\n";

    return ( $methodCode );
}

## Called by writeClassDoc
sub generateAllMethods($$$$$$)
{
    my ($classNode, $ancestorCount, $csharpMethods, $mainClassNode, $generateConstructors, $addImport) = @_;
    my $methodCode = '';
    my $staticMethodCode = '';
    my $interfaceCode = '';
    my $proxyInterfaceCode = '';
    my $signalCode = '';
    my $notConverted = '';
    my $extraCode = '';
    my $enumCode = '';
    $methodNumber = 0;
    my $className = join( "::", kdocAstUtil::heritage($classNode) );
	my $csharpClassName = $mainClassNode->{astNodeName};
	# If the C++ class had multiple inheritance, then the code for all but one of the
	# parents must be copied into the code for csharpClassName. Hence, for QWidget current
	# classname might be QPaintDevice, as its methods are needed in QWidget.
	my $currentClassName = join( ".", kdocAstUtil::heritage($classNode) );

    my $sourcename = $classNode->{Source}->{astNodeName};
    
	if ( $sourcename !~ s!.*(kio/|kparts/|dom/|kabc/|ksettings/|kjs/|ktexteditor/|kdeprint/|kdesu/)(.*)!$1$2!m ) {
    	$sourcename =~ s!.*/(.*)!$1!m;
	}
    die "Empty source name for $classNode->{astNodeName}" if ( $sourcename eq '' );
		
    $addImport->{"Qyoto"} = 1;
	if ($className =~ /^Plasma::/) {
		$addImport->{"Kimono"} = 1;
	}

	my %virtualMethods;
	allVirtualMethods( $classNode, \%virtualMethods, $classNode );

	my %overridenMethods;
	allOverridenMethods( $classNode, \%overridenMethods, $classNode );
	
	for my $sig (keys %overridenMethods) {
#		print("$currentClassName sig: $overridenMethods{$sig}{class}->{astNodeName}::$sig\n");
	}
	
    Iter::MembersByType ( $classNode, undef,
			  sub {	my ($classNode, $methodNode ) = @_;
				
	if ( $methodNode->{NodeType} eq 'enum' and $classNode->{astNodeName} eq $mainClassNode->{astNodeName} ) {
	    my ($code) = generateEnum( $classNode, $methodNode, 0 );
	    $enumCode .= $code;
	}
				}, undef );
	
    # Do all enums first, anonymous ones and then named enums
    Iter::MembersByType ( $classNode, undef,
			  sub {	my ($classNode, $methodNode ) = @_;
			
	if ( $methodNode->{NodeType} eq 'enum' and $classNode->{astNodeName} eq $mainClassNode->{astNodeName} ) {
	    my ($code) = generateEnum( $classNode, $methodNode, 1 );
	    $extraCode .= $code;
	}
				}, undef );

    # Then all static vars
    Iter::MembersByType ( $classNode, undef,
			  sub {	my ($classNode, $methodNode ) = @_;
				
	if ( $methodNode->{NodeType} eq 'var' and $classNode->{astNodeName} eq $mainClassNode->{astNodeName} ) {
	    my ($code, $interface, $proxyInterface) = generateVar( $classNode, $methodNode, $addImport );
	    $extraCode .= $code;
	    $interfaceCode .= $interface;
	    $proxyInterfaceCode .= $proxyInterface;
	}
				}, undef );

    # Then all properties
    Iter::MembersByType ( $classNode, undef,
			  sub {	my ($classNode, $methodNode ) = @_;
				
	if ( $methodNode->{NodeType} eq 'property' and $classNode->{astNodeName} eq $mainClassNode->{astNodeName} ) {
	    my ($code, $interface) = generateProperty( \%overridenMethods, $classNode, $methodNode, $addImport );
	    $extraCode .= $code;
	}
				}, undef );

	my %non_const_methods = ();
	
	# build const-methods table
     Iter::MembersByType ( $classNode, undef,
		sub {	my ($classNode, $m ) = @_;
	
		next unless $m->{NodeType} eq 'method';
		my @args = @{ $m->{ParamList} };
	    my $sig = methodSignature( $m, $#args );
		if ( $sig !~ /(.*) const$/ ) {
			$non_const_methods{"$sig const"} = 1;
		}
		
		      }, undef );

    # Then all methods
    Iter::MembersByType ( $classNode, undef,
			  sub {	my ($classNode, $methodNode ) = @_;

        if ( $methodNode->{NodeType} eq 'method' ) {
	    	my @args = @{ $methodNode->{ParamList} };
	    	my $sig = methodSignature( $methodNode, $#args );
	    	# prefer non-const methods over const methods, same as in the smoke lib
	    	return if ( $non_const_methods{$sig} && $methodNode->{Flags} !~ "v" );

	    	my ($meth, $static, $interface, $proxyInterface, $signals, $notconv) = generateMethod( \%virtualMethods, \%overridenMethods, $classNode, $methodNode, $addImport, $ancestorCount, $csharpMethods, $mainClassNode, $generateConstructors );
	    	$methodCode .= $meth;
	    	$staticMethodCode .= $static;
	    	$interfaceCode .= $interface;
	    	$proxyInterfaceCode .= $proxyInterface;
			$signalCode .= $signals;
			$notConverted .= $notconv;
		}
			      }, undef );
	
	for my $sig (keys %virtualMethods) {
		if (	$virtualMethods{$sig}{method}->{Flags} =~ /[p]/ 
				&&  $classNode->{astNodeName} ne $virtualMethods{$sig}{class}->{astNodeName}
				&& ! exists $classNode->{Pure} )
		{
			# If a pure virtual method in the superclass hasn't been overriden, then C++ will 
			# assume it is still ok to instantiate instances of the class as long as it hasn't got
			# its own pure virtual methods. However, in C# this isn't allowed, and so we need 
			# to add 'dummy' method calls here to cover the non-overriden pure virtual methods,
			# and avoid needing to make the class abstract.
			my $docNode = $virtualMethods{$sig}{method}->{DocNode};
			$virtualMethods{$sig}{method}->{DocNode} = undef;
	    	my ($meth, $static, $interface, $proxyInterface, $signals, $notconv) = generateMethod( \%virtualMethods, \%overridenMethods, $classNode, $virtualMethods{$sig}{method}, $addImport, $ancestorCount, $csharpMethods, $mainClassNode, $generateConstructors );	    	
			$virtualMethods{$sig}{method}->{DocNode} = $docNode;
			if ( $meth =~ /override/ ) {
				$methodCode .= "        // WARNING: Unimplemented C++ pure virtual - DO NOT CALL\n";
				$methodCode .= $meth;
	    		$staticMethodCode .= $static;
	    		$interfaceCode .= $interface;
	    		$proxyInterfaceCode .= $proxyInterface;
				$signalCode .= $signals;
				$notConverted .= $notconv;
			}
		}
	}

    if (	$classNode->{astNodeName} eq $csharpClassName 
			&& $classNode->{HasPublicDestructor} 
			&& $classNode->{CanBeInstanciated}
			&& !$classNode->{Pure} ) 
	{
    	if ( $generateConstructors && $csharpClassName ne 'Qt' ) {
			$methodCode .= "        ~$csharpClassName() {\n";
            if ($csharpClassName eq 'QModelIndex') {
				$methodCode .= "            QAbstractItemModel.DerefIndexHandle(InternalPointer());\n";
			}
			$methodCode .= "            interceptor.Invoke(\"~$classNode->{astNodeName}\", \"~$classNode->{astNodeName}()\", typeof(void));\n        }\n";
			
			my $overridenMethod = $overridenMethods{~$classNode->{astNodeName}}{method};
			if (	defined $overridenMethod
					&& $classNode->{astNodeName} ne 'QObject'
				 	&& (	$ancestorCount == 1 
							|| !defined $interfacemap{$overridenMethod->{Parent}->{astNodeName}} ) )
			{
				$methodCode .= "        public new ";
			} else {
				$methodCode .= "        public ";
			}
			$methodCode .= "void Dispose() {\n";
            if ($csharpClassName eq 'QModelIndex') {
				$methodCode .= "            QAbstractItemModel.DerefIndexHandle(InternalPointer());\n";
			}
			$methodCode .= "            interceptor.Invoke(\"~$classNode->{astNodeName}\", \"~$classNode->{astNodeName}()\", typeof(void));\n        }\n";
		}
			$methodNumber++;
    }
                                                               
    return ( $methodCode, $staticMethodCode, $interfaceCode, $proxyInterfaceCode, $signalCode, $extraCode, $enumCode, $notConverted );
}

# Return 0 if the class has no virtual dtor, 1 if it has, 2 if it's private
sub hasVirtualDestructor($$)
{
    my ( $classNode, $startNode ) = @_;
    my $className = join( "::", kdocAstUtil::heritage($classNode) );
    return if ( $skippedClasses{$className} || defined $interfacemap{$className} );

    my $parentHasIt;
    # Look at ancestors, and (recursively) call hasVirtualDestructor for each
    # It's enough to have one parent with a prot/public virtual dtor
    Iter::Ancestors( $classNode, $rootnode, undef, undef, sub {
                     my $vd = hasVirtualDestructor( $_[0], $_[1] );
                     $parentHasIt = $vd unless $parentHasIt > $vd;
                    } );
    return $parentHasIt if $parentHasIt; # 1 or 2

    # Now look in $classNode - including private methods
    my $doPrivate = $main::doPrivate;
    $main::doPrivate = 1;
    my $result;
    Iter::MembersByType ( $classNode, undef,
		sub {	my ($classNode, $m ) = @_;
			return unless( $m->{NodeType} eq "method" && $m->{ReturnType} eq '~' );

			if ( $m->{Flags} =~ /[vp]/ && $classNode != $startNode) {
			    if ( $m->{Access} =~ /private/ ) {
				$result=2; # private virtual
			    } else {
				$result=1; # [protected or public] virtual
			    }
			}
		},
		undef
	);
    $main::doPrivate = $doPrivate;
    $result=0 if (!defined $result);
    return $result;
}

=head2 allVirtualMethods

	Parameters: class node, dict

	Adds to the dict, for all method nodes that are virtual, in this class and in parent classes :
        {method} the method node, {class} the class node (the one where the virtual is implemented)

=cut

sub allVirtualMethods($$$)
{
    my ( $classNode, $virtualMethods, $startNode ) = @_;
    my $className = join( "::", kdocAstUtil::heritage($classNode) );
    return if ( $skippedClasses{$className} );

    # Look at ancestors, and (recursively) call allVirtualMethods for each
    # This is done first, so that virtual methods that are reimplemented as 'private'
    # can be removed from the list afterwards (below)
    Iter::Ancestors( $classNode, $rootnode, undef, undef, sub {
			 allVirtualMethods( @_[0], $virtualMethods, $startNode );
		     }, undef
		   );

    # Now look for virtual methods in $classNode - including private ones
    my $doPrivate = $main::doPrivate;
    $main::doPrivate = 1;
    Iter::MembersByType ( $classNode, undef,
		sub {	my ($classNode, $m ) = @_;
			# Only interested in methods, and skip destructors
			return unless( $m->{NodeType} eq "method" && $m->{ReturnType} ne '~' );

			my @args = @{ $m->{ParamList} };
			my $last = $m->{FirstDefaultParam};
			$last = scalar @args unless defined $last;
			my $iterationCount = scalar(@args) - $last;
			while($iterationCount >= 0) {
				my $signature = methodSignature( $m, $#args );
				print STDERR $signature . " ($m->{Access})\n" if ($debug);

				# A method is virtual if marked as such (v=virtual p=pure virtual)
				# or if a parent method with same signature was virtual
				if ( $m->{Flags} =~ /[vp]/ or defined $virtualMethods->{$signature} ) {
					if ( $m->{Access} =~ /private/ ) {
						if ( defined $virtualMethods->{$signature} ) { # remove previously defined
							delete $virtualMethods->{$signature};
						}
						# else, nothing, just ignore private virtual method
					} elsif ( $classNode->{astNodeName} ne $startNode->{astNodeName} ) {
						$virtualMethods->{$signature}{method} = $m;
						$virtualMethods->{$signature}{class} = $classNode;
					}
				}

				pop @args;
				$iterationCount--;
			}
		},
		undef
	);
    $main::doPrivate = $doPrivate;
}

sub allOverridenMethods($$$)
{
    my ( $classNode, $overridenMethods, $startNode ) = @_;
    my $className = join( "::", kdocAstUtil::heritage($classNode) );
    return if ( $skippedClasses{$className} );

	my $qtnode;
	if ( $classNode->{astNodeName} eq 'QObject' ) {
		$qtnode = kdocAstUtil::findRef( $rootnode, "Qt" );
		if ( defined $qtnode ) {
			allOverridenMethods( $qtnode, $overridenMethods, $startNode );
		}
	}

    Iter::Ancestors( $classNode, $qtnode, undef, undef, sub {
			 allOverridenMethods( @_[0], $overridenMethods, $startNode );
		     }, undef
		   );

    # Look at ancestors, and (recursively) call allOverridenMethods for each
    # This is done first, so that virtual methods that are reimplemented as 'private'
    # can be removed from the list afterwards (below)
    Iter::Ancestors( $classNode, $rootnode, undef, undef, sub {
			 allOverridenMethods( @_[0], $overridenMethods, $startNode );
		     }, undef
		   );

    # Now look for virtual methods in $classNode - including private ones
    Iter::MembersByType ( $classNode, undef,
		sub {	my ($classNode, $m ) = @_;
			# Only interested in methods, and skip destructors
			return unless( $m->{NodeType} eq "method" or $m->{NodeType} eq "enum" or $m->{NodeType} eq "property" );

			my $signature = methodSignature( $m, $#{$m->{ParamList}} );
			print STDERR $signature . " ($m->{Access})\n" if ($debug);

			if ( $classNode->{astNodeName} ne $startNode->{astNodeName} && $classNode->{astNodeName} ne 'Global' ) {
				if ( $m->{NodeType} eq "enum" ) {
					$overridenMethods->{$m->{astNodeName}}{method} = $m;
					$overridenMethods->{$m->{astNodeName}}{class} = $classNode;
				} elsif ( $m->{NodeType} eq "property" ) {
					my $name = $m->{astNodeName};
					if ( $name =~ s/Q_PROPERTY_([a-z])(.*)// ) {
						$name = uc($1) . $2;
					}

					$overridenMethods->{$name}{method} = $m;
					$overridenMethods->{$name}{class} = $classNode;
				} elsif ( $m->{ReturnType} eq '~' ) {
					if ( ! exists $classNode->{Pure} ) {
						$overridenMethods->{~$startNode->{astNodeName}}{method} = $m;
						$overridenMethods->{~$startNode->{astNodeName}}{class} = $classNode;
					}
				} elsif ( $m->{Access} =~ /private/ ) {
					if ( defined $overridenMethods->{$signature} ) { # remove previously defined
						delete $overridenMethods->{$signature};
					}
					# else, nothing, just ignore private virtual method
				} else {
					my @args = @{ $m->{ParamList} };
					my $last = $m->{FirstDefaultParam};
					$last = scalar @args unless defined $last;
					my $iterationCount = scalar(@args) - $last;
					while($iterationCount >= 0) {
	    				my $signature = methodSignature( $m, $#args );

    					my $propertyName = $m->{astNodeName};
    					if ( @{$m->{ParamList}} == 1 && $propertyName =~ /^set(.)(.*)/ ) {
							$propertyName = "Q_PROPERTY_" . lc($1) . $2;
							my $item = kdocAstUtil::findRef( $classNode, $propertyName );
							if ( defined $item && $item->{NodeType} eq 'property' ) {
        						# If there is a property with the same name, don't bother
								$signature = "";
							}
						}


						if ($signature ne "") {
							$overridenMethods->{$signature}{method} = $m;
							$overridenMethods->{$signature}{class} = $classNode;
						}

						pop @args;
						$iterationCount--;
					}
				}
			}
		},
		undef
	);
}

# Known typedef? If so, apply it.
sub applyTypeDef($)
{
    my $type = shift;
    # Parse 'const' in front of it, and '*' or '&' after it
    my $prefix = $type =~ s/^const\s+// ? 'const ' : '';
    my $suffix = $type =~ s/\s*([\&\*]+)$// ? $1 : '';

    if (exists $typedeflist{$type}) {
	return $prefix.$typedeflist{$type}.$suffix;
    }
    return $prefix.$type.$suffix;
}

# Register type ($1) into %allTypes if not already there
sub registerType($$) {
    my $type = shift;
    #print "registerType: $type\n" if ($debug);

    $type =~ s/\s+const$//; # for 'char* const'
    $type =~ s/\s+const\s*\*$/\*/; # for 'char* const*'

    return if ( $type eq 'void' or $type eq '' or $type eq '~' );
    die if ( $type eq '...' );     # ouch

    # Let's register the real type, not its known equivalent
    #$type = applyTypeDef($type);

    # Enum _value_ -> get corresponding type
    if (exists $enumValueToType{$type}) {
	$type = $enumValueToType{$type};
    }

    # Already in allTypes
    if(exists $allTypes{$type}) {
        return;
    }

    die if $type eq 'QTextEdit::UndoRedoInfo::Type';
    die if $type eq '';

    my $realType = $type;

    # Look for references (&) and pointers (* or **)  - this will not handle *& correctly.
    # We do this parsing here because both the type list and iterproto need it
    if($realType =~ s/&$//) {
	$allTypes{$type}{typeFlags} = 'Smoke::tf_ref';
    }
    elsif($realType ne 'void*' && $realType =~ s/\*$//) {
	$allTypes{$type}{typeFlags} = 'Smoke::tf_ptr';
    }
    else {
	$allTypes{$type}{typeFlags} = 'Smoke::tf_stack';
    }

    if ( $realType =~ s/^const\s+// ) { # Remove 'const'
	$allTypes{$type}{typeFlags} .= ' | Smoke::tf_const';
    }

    # Apply typedefs, and store the resulting type.
    # For instance, if $type was Q_UINT16&, realType will be ushort
    $allTypes{$type}{realType} = applyTypeDef( $realType );

    # In the first phase we only create entries into allTypes.
    # The values (indexes) are calculated afterwards, once the list is full.
    $allTypes{$type}{index} = -1;
    #print STDERR "Register $type. Realtype: $realType\n" if($debug);
}

# Get type from %allTypes
# This returns a hash with {index}, {isEnum}, {typeFlags}, {realType}
# (and {typeId} after the types array is written by writeSmokeDataFile)
sub findTypeEntry($) {
    my $type = shift;
    my $typeIndex = -1;
    $type =~ s/\s+const$//; # for 'char* const'
    $type =~ s/\s+const\s*\*$/\*/; # for 'char* const*'

    return undef if ( $type =~ '~' or $type eq 'void' or $type eq '' );

    # Enum _value_ -> get corresponding type
    if (exists $enumValueToType{$type}) {
	$type = $enumValueToType{$type};
    }

	if ( ! defined $allTypes{$type} ) {
    	print("type not known: $type\n");
		return undef;
	}

#    die "type not known: $type" unless defined $allTypes{$type};
    return $allTypes{ $type };
}

# List of all csharp super-classes for a given class, via single inheritance. 
# Excluding any which are mapped onto interfaces to avoid multiple inheritance.
sub direct_superclass_list($)
{
    my $classNode = shift;
    my @super;
	my $has_ancestor = 0;
	my $direct_ancestor = undef;
	my $name;
	
    Iter::Ancestors( $classNode, $rootnode, undef, undef, sub {
			( $direct_ancestor, $name ) = @_;
			if ($name =~ /QMemArray|QSqlFieldInfoList/) {
				# Template classes, give up for now..
				$has_ancestor = 1;
			} elsif (!defined $interfacemap{$name}) {
				push @super, $direct_ancestor;
				push @super, direct_superclass_list( $direct_ancestor );
				$has_ancestor = 1;
			}
		     }, undef );
	
	if (! $has_ancestor and defined $direct_ancestor) {
		push @super, $direct_ancestor;
    	push @super, direct_superclass_list( $direct_ancestor );
	}
	
	return @super;
}

# List of all super-classes for a given class
sub superclass_list($)
{
    my $classNode = shift;
    my @super;
    Iter::Ancestors( $classNode, $rootnode, undef, undef, sub {
			push @super, @_[0];
			push @super, superclass_list( @_[0] );
		     }, undef );
    return @super;
}

sub is_kindof($$)
{
    my $classNode = shift;
	my $className = shift;
	
	if ($classNode->{astNodeName} eq $className) {
		return 1;
	}
	
	my @superclasses = superclass_list($classNode);
	foreach my $ancestor (@superclasses) {
		if ($ancestor->{astNodeName} eq $className) {
			return 1;
		}
	}
	
	return 0;
}

# Store the {case} dict in the class Node (method signature -> index in the "case" switch)
# This also determines which methods should NOT be in the switch, and sets {SkipFromSwitch} for them
sub prepareCaseDict($) {

     my $classNode = shift;
     my $className = join( "::", kdocAstUtil::heritage($classNode) );
     $classNode->AddProp("case", {});
     my $methodNumber = 0;

     # First look at all enums for this class
     Iter::MembersByType ( $classNode, undef,
		sub {	my ($classNode, $m ) = @_;

	next unless $m->{NodeType} eq 'enum';
	foreach my $val ( @{$m->{ParamList}} ) {
	    my $fullEnumName = "$className\::".$val->{ArgName};
	    print STDERR "Enum: $fullEnumName -> case $methodNumber\n" if ($debug);
	    $classNode->{case}{$fullEnumName} = $methodNumber;
	    $enumValueToType{$fullEnumName} = "$className\::$m->{astNodeName}";
	    $methodNumber++;
	}
		      }, undef );

     # Check for static vars
     Iter::MembersByType ( $classNode, undef,
		sub {	my ($classNode, $m ) = @_;

	    next unless $m->{NodeType} eq 'var';
	    my $name = "$className\::".$m->{astNodeName};			
	    print STDERR "Var: $name -> case $methodNumber\n" if ($debug);
	    $classNode->{case}{$name} = $methodNumber;
	    $methodNumber++;

		      }, undef );


     # Now look at all methods for this class
     Iter::MembersByType ( $classNode, undef,
		sub {	my ($classNode, $m ) = @_;

	next unless $m->{NodeType} eq 'method';
	my $name = $m->{astNodeName};
        my $isConstructor = ($name eq $classNode->{astNodeName} );
	if ($isConstructor and ($m->{ReturnType} eq '~')) # destructor
	{
	    # Remember whether we'll generate a switch entry for the destructor
	    $m->{SkipFromSwitch} = 1 unless ($classNode->{CanBeInstanciated} and $classNode->{HasPublicDestructor});
	    next;
	}

        # Don't generate bindings for protected methods (incl. signals) if
        # we're not deriving from the C++ class. Only take public and public_slots
        my $ok = ( $classNode->{BindingDerives} or $m->{Access} =~ /public/ ) ? 1 : 0;

        # Don't generate bindings for pure virtuals - we can't call them ;)
        $ok = 0 if ( $ok && $m->{Flags} =~ "p" );

        # Bugfix for Qt-3.0.4: those methods are NOT implemented (report sent).
        $ok = 0 if ( $ok && $className eq 'QLineEdit' && ( $name eq 'setPasswordChar' || $name eq 'passwordChar' ) );
        $ok = 0 if ( $ok && $className eq 'QWidgetItem' && $name eq 'widgetSizeHint' );

        if ( !$ok )
        {
	    #print STDERR "Skipping $className\::$name\n" if ($debug);
	    $m->{SkipFromSwitch} = 1;
	    next;
	}

	my @args = @{ $m->{ParamList} };
	my $last = $m->{FirstDefaultParam};
	$last = scalar @args unless defined $last;
	my $iterationCount = scalar(@args) - $last;
	while($iterationCount >= 0) {
	    my $sig = methodSignature( $m, $#args );
	    $classNode->{case}{$sig} = $methodNumber;
	    #print STDERR "prepareCaseDict: registered case number $methodNumber for $sig in $className()\n" if ($debug);
	    pop @args;
	    $iterationCount--;
	    $methodNumber++;
	}
		    }, undef );

    # Add the destructor, at the end
    if ($classNode->{CanBeInstanciated} and $classNode->{HasPublicDestructor}) {
        $classNode->{case}{"~$className()"} = $methodNumber;
	# workaround for ~Sub::Class() being seen as Sub::~Class()
	$classNode->{case}{"~$classNode->{astNodeName}()"} = $methodNumber;
	#print STDERR "prepareCaseDict: registered case number $methodNumber for ~$className()\n" if ($debug);
    }
}

sub writeSmokeDataFile($) {
    my $rootnode = shift;

    # Make list of classes
    my %allImports; # list of all header files for all classes
    my @classlist;
    push @classlist, ""; # Prepend empty item for "no class"
    my %enumclasslist;
    Iter::LocalCompounds( $rootnode, sub {
	my $classNode = $_[0];
	my $className = join( "::", kdocAstUtil::heritage($classNode) );
	
	return if $classNode->{NodeType} eq 'namespace';
	
	push @classlist, $className;
	$enumclasslist{$className}++ if keys %{$classNode->{enumerations}};
	$classNode->{ClassIndex} = $#classlist;
	addImportForClass( $classNode, \%allImports, undef );
    } );

    my %classidx = do { my $i = 0; map { $_ => $i++ } @classlist };

    my $file = "$outputdir/smokedata.cpp";
#    open OUT, ">$file" or die "Couldn't create $file\n";

#    foreach my $incl (sort{ 
#                           return 1 if $a=~/qmotif/;  # move qmotif* at bottom (they include dirty X11 headers)
#                           return -1 if $b=~/qmotif/;
#			   return -1 if substr($a,0,1) eq 'q' and substr($b,0,1) ne 'q'; # move Qt headers on top
#			   return 1 if substr($a,0,1) ne 'q' and substr($b,0,1) eq 'q';			   
#                           $a cmp $b
#                          } keys %allIncludes) {
#	die if $imp eq '';
#	print OUT "import $imp;\n";
#    }	

#    print OUT "\n";

    print STDERR "Writing ${libname}_cast function\n" if ($debug);

    # Prepare descendants information for each class
    my %descendants; # classname -> list of descendant nodes
    Iter::LocalCompounds( $rootnode, sub {
	my $classNode = shift;
	# Get _all_ superclasses (up any number of levels)
	# and store that $classNode is a descendant of $s
	my @super = superclass_list($classNode);
	for my $s (@super) {
	    my $superClassName = join( "::", kdocAstUtil::heritage($s) );
	    Ast::AddPropList( \%descendants, $superClassName, $classNode );
	}
    } );

    # Iterate over all classes, to write the xtypecast function
    Iter::LocalCompounds( $rootnode, sub {
	my $classNode = shift;
	my $className = join( "::", kdocAstUtil::heritage($classNode) );
	# @super will contain superclasses, the class itself, and all descendants
	my @super = superclass_list($classNode);
	push @super, $classNode;
        if ( defined $descendants{$className} ) {
	    push @super, @{$descendants{$className}};
	}
	my $cur = $classidx{$className};
	
	return if $classNode->{NodeType} eq 'namespace';

#	print OUT "      case $cur:    //$className\n";
#	print OUT "    switch(to) {\n";
#	$cur = -1;
#	my %casevalues;
#	for my $s (@super) {
#		my $superClassName = join( "::", kdocAstUtil::heritage($s) );
#		next if !defined $classidx{$superClassName}; # inherits from unknown class, see below
#		next if $classidx{$superClassName} == $cur;    # shouldn't happen in Qt
#		next if $s->kdocAstUtil::inheritsAsVirtual($classNode); # can't cast from a virtual base class
#		$cur = $classidx{$superClassName}; # KDE has MI with diamond shaped cycles (cf. KXMLGUIClient)
#		next if $casevalues{$cur};         # ..so skip any duplicate parents
#		print OUT "      case $cur: return (void*)($superClassName*)($className*)xptr;\n";
#		$casevalues{$cur} = 1;
#	}
#	print OUT "      default: return xptr;\n";
#	print OUT "    }\n";
    } );
#    print OUT "      default: return xptr;\n";
#    print OUT "    }\n";
#    print OUT "}\n\n";


    # Write inheritance array
    # Imagine you have "Class : public super1, super2"
    # The inheritlist array will get 3 new items: super1, super2, 0
    my %inheritfinder;  # key = (super1, super2) -> data = (index in @inheritlist). This one allows reuse.
    my %classinherit;   # we store that index in %classinherit{className}
    # We don't actually need to store inheritlist in memory, we write it
    # directly to the file. We only need to remember its current size.
    my $inheritlistsize = 1;

#    print OUT "// Group of class IDs (0 separated) used as super class lists.\n";
#    print OUT "// Classes with super classes have an index into this array.\n";
#    print OUT "static short ${libname}_inheritanceList[] = {\n";
#    print OUT "    0,    // 0: (no super class)\n";
    Iter::LocalCompounds( $rootnode, sub {
	my $classNode = shift;
	my $className = join( "__", kdocAstUtil::heritage($classNode) );
	
	return if $classNode->{NodeType} eq 'namespace';
	
	print STDERR "inheritanceList: looking at $className\n" if ($debug);

	# Make list of direct ancestors
	my @super;
	Iter::Ancestors( $classNode, $rootnode, undef, undef, sub {
			     my $superClassName = join( "::", kdocAstUtil::heritage($_[0]) );
			     push @super, $superClassName;
		    }, undef );
	# Turn that into a list of class indexes
	my $key = '';
	foreach my $superClass( @super ) {
	    if (defined $classidx{$superClass}) {
		$key .= ', ' if ( length $key > 0 );
		$key .= $classidx{$superClass};
	    }
	}
	if ( $key ne '' ) {
	    if ( !defined $inheritfinder{$key} ) {
		print OUT "    ";
		my $index = $inheritlistsize; # Index of first entry (for this group) in inheritlist
		foreach my $superClass( @super ) {
		    if (defined $classidx{$superClass}) {
			print OUT "$classidx{$superClass}, ";
			$inheritlistsize++;
		    }
		}
		$inheritlistsize++;
		my $comment = join( ", ", @super );
		print OUT "0,    // $index: $comment\n";
		$inheritfinder{$key} = $index;
	    }
	    $classinherit{$className} = $inheritfinder{$key};
	} else { # No superclass
	    $classinherit{$className} = 0;
	}
    } );
#    print OUT "};\n\n";


#    print OUT "// These are the xenum functions for manipulating enum pointers\n";
    for my $className (keys %enumclasslist) {
	my $c = $className;
	$c =~ s/::/__/g;
#	print OUT "void xenum_$c\(Smoke::EnumOperation, Smoke::Index, void*&, long&);\n";
    }
#    print OUT "\n";
#    print OUT "// Those are the xcall functions defined in each x_*.cpp file, for dispatching method calls\n";
    my $firstClass = 1;
    for my $className (@classlist) {
	if ($firstClass) {
	    $firstClass = 0;
	    next;
	}
	my $c = $className;   # make a copy
	$c =~ s/::/__/g;
#	print OUT "void xcall_$c\(Smoke::Index, void*, Smoke::Stack);\n";
    }
#    print OUT "\n";

    # Write class list afterwards because it needs offsets to the inheritance array.
#    print OUT "// List of all classes\n";
#    print OUT "// Name, index into inheritanceList, method dispatcher, enum dispatcher, class flags\n";
#    print OUT "static Smoke::Class ${libname}_classes[] = {\n";
    my $firstClass = 1;
    Iter::LocalCompounds( $rootnode, sub {
	my $classNode = shift;
	my $className = join( "__", kdocAstUtil::heritage($classNode) );
	
	return if $classNode->{NodeType} eq 'namespace';

	if ($firstClass) {
	    $firstClass = 0;
	    print OUT "    { 0L, 0, 0, 0, 0 },     // 0 (no class)\n";
	}
	my $c = $className;
	$c =~ s/::/__/g;
	my $xcallFunc = "xcall_$c";
	my $xenumFunc = "0";
	$xenumFunc = "xenum_$c" if exists $enumclasslist{$className};
	# %classinherit needs Foo__Bar, not Foo::Bar?
	die "problem with $className" unless defined $classinherit{$c};

	my $xClassFlags = 0;
	$xClassFlags .= "|Smoke::cf_constructor" if $classNode->{CanBeInstanciated}; # correct?
	$xClassFlags .= "|Smoke::cf_deepcopy" if $classNode->{CanBeCopied}; # HasCopyConstructor would be wrong (when it's private)
	$xClassFlags .= "|Smoke::cf_virtual" if hasVirtualDestructor($classNode, $classNode) == 1;
	# $xClassFlags .= "|Smoke::cf_undefined" if ...;
	$xClassFlags =~ s/0\|//; # beautify
#	print OUT "    { \"$className\", $classinherit{$c}, $xcallFunc, $xenumFunc, $xClassFlags },     //$classidx{$className}\n";
    } );
#    print OUT "};\n\n";


#    print OUT "// List of all types needed by the methods (arguments and return values)\n";
#    print OUT "// Name, class ID if arg is a class, and TypeId\n";
#    print OUT "static Smoke::Type ${libname}_types[] = {\n";
    my $typeCount = 0;
    $allTypes{''}{index} = 0; # We need an "item 0"
    for my $type (sort keys %allTypes) {
	$allTypes{$type}{index} = $typeCount;      # Register proper index in allTypes
	if ( $typeCount == 0 ) {
#	    print OUT "    { 0, 0, 0 },    //0 (no type)\n";
	    $typeCount++;
	    next;
	}
	my $isEnum = $allTypes{$type}{isEnum};
	my $typeId;
	my $typeFlags = $allTypes{$type}{typeFlags};
	my $realType = $allTypes{$type}{realType};
	die "$type" if !defined $typeFlags;
#	die "$realType" if $realType =~ /\(/;
	# First write the name
#	print OUT "    { \"$type\", ";
	# Then write the classId (and find out the typeid at the same time)
	if(exists $classidx{$realType}) { # this one first, we want t_class for QBlah*
	    $typeId = 't_class';
#	    print OUT "$classidx{$realType}, ";
	}
	elsif($type =~ /&$/ || $type =~ /\*$/) {
	    $typeId = 't_voidp';
#	    print OUT "0, "; # no classId
	}
	elsif($isEnum || $allTypes{$realType}{isEnum}) {
	    $typeId = 't_enum';
	    if($realType =~ /(.*)::/) {
		my $c = $1;
		if($classidx{$c}) {
#		    print OUT "$classidx{$c}, ";
		} else {
#		    print OUT "0 /* unknown class $c */, ";
		}
	    } else {
#		print OUT "0 /* unknown $realType */, "; # no classId
	    }
	}
	else {
	    $typeId = $typeunion{$realType};
	    if (defined $typeId) {
		$typeId =~ s/s_/t_/; # from s_short to t_short for instance
	    }
	    else {
		# Not a known class - ouch, this happens quite a lot
		# (private classes, typedefs, template-based types, etc)
		if ( $skippedClasses{$realType} ) {
#		    print STDERR "$realType has been skipped, using t_voidp for it\n";
		} else {
		    unless( $realType =~ /</ ) { # Don't warn for template stuff...
			print STDERR "$realType isn't a known type (type=$type)\n";
		    }
		}
		$typeId = 't_voidp'; # Unknown -> map to a void *
	    }
#	    print OUT "0, "; # no classId
	}
	# Then write the flags
	die "$type" if !defined $typeId;
#	print OUT "Smoke::$typeId | $typeFlags },";
#	print OUT "    //$typeCount\n";
	$typeCount++;
	# Remember it for coerce_type
	$allTypes{$type}{typeId} = $typeId;
    }
#    print OUT "};\n\n";


    my %arglist; # registers the needs for argumentList (groups of type ids)
    my %methods;
    # Look for all methods and all enums, in all classes
    # And fill in methods and arglist. This loop writes nothing to OUT.
    Iter::LocalCompounds( $rootnode, sub {
	my $classNode = shift;
	my $className = join( "::", kdocAstUtil::heritage($classNode) );
	print STDERR "writeSmokeDataFile: arglist: looking at $className\n" if ($debug);

	Iter::MembersByType ( $classNode, undef,
		sub {	my ($classNode, $m ) = @_;

	my $methName = $m->{astNodeName};
	# For destructors, get a proper signature that includes the '~'
	if ( $m->{ReturnType} eq '~' )
	{
	    $methName = '~' . $methName ;
	    # Let's even store that change, otherwise we have to do it many times
	    $m->{astNodeName} = $methName;
	}
	
	if( $m->{NodeType} eq "enum" ) {

	    foreach my $enum ( @{$m->{ParamList}} ) {
		my $enumName = $enum->{ArgName};
	        $methods{$enumName}++;
	    }

        } elsif ( $m->{NodeType} eq 'var' ) {

	    $methods{$m->{astNodeName}}++;

	} elsif( $m->{NodeType} eq "method" ) {

	    $methods{$methName}++;
	    my @protos;
	    makeprotos(\%classidx, $m, \@protos);

	    #print "made @protos from $className $methName $m->{Signature})\n" if ($debug);
	    for my $p (@protos) {
			$methods{$p}++;
			my $argcnt = 0;
			$argcnt = length($1) if $p =~ /([\$\#\?]+)/;
			my $sig = methodSignature($m, $argcnt-1);
			# Store in a class hash named "proto", a proto+signature => method association
			$classNode->{proto}{$p}{$sig} = $m;
			#$classNode->{signature}{$sig} = $p;
			# There's probably a way to do this better, but this is the fastest way
			# to get the old code going: store classname into method
			$m->{class} = $className;
	    }

	    my $firstDefaultParam = $m->{FirstDefaultParam};
	    $firstDefaultParam = scalar(@{ $m->{ParamList} }) unless defined $firstDefaultParam;
	    my $argNames = '';
	    my $args = '';
	    for(my $i = 0; $i < @{ $m->{ParamList} }; $i++) {
		$args .= ', ' if $i;
		$argNames .= ', ' if $i;
		my $argType = $m->{ParamList}[$i]{ArgType};
		my $typeEntry = findTypeEntry( $argType );
		$args .= defined $typeEntry ? $typeEntry->{index} : 0;
		$argNames .= $argType;

		if($i >= ($firstDefaultParam - 1)) {
		    #print "arglist entry: $args\n";
		    $arglist{$args} = $argNames;
		}
		
	    }
	    # create an entry for e.g. "arg0,arg1,arg2" where argN is index in allTypes of type for argN
	    # The value, $argNames, is temporarily stored, to be written out as comment
	    # It gets replaced with the index in the next loop.
	    #print "arglist entry : $args\n";
	    $arglist{$args} = $argNames;
	}
		    }, # end of sub
	undef
       );
    });


    $arglist{''} = 0;
    # Print arguments array
#    print OUT "static Smoke::Index ${libname}_argumentList[] = {\n";
    my $argListCount = 0;
    for my $args (sort keys %arglist) {
	my @dunnohowtoavoidthat = split(',',$args);
	my $numTypes = $#dunnohowtoavoidthat;
	if ($args eq '') {
#	    print OUT "    0,    //0  (void)\n";
	} else {
	    # This is a nice trick : args can be written in one go ;)
#	    print OUT "    $args, 0,    //$argListCount  $arglist{$args}  \n";
	}
	$arglist{$args} = $argListCount;      # Register proper index in argList
	$argListCount += $numTypes + 2;       # Move forward by as much as we wrote out
    }
#    print OUT "};\n\n";

    $methods{''} = 0;
    my @methodlist = sort keys %methods;
    my %methodidx = do { my $i = 0; map { $_ => $i++ } @methodlist };

#    print OUT "// Raw list of all methods, using munged names\n";
#    print OUT "static const char *${libname}_methodNames[] = {\n";
    my $methodNameCount = $#methodlist;
    for my $m (@methodlist) {
#	print OUT qq(    "$m",    //$methodidx{$m}\n);
    }
#    print OUT "};\n\n";

#    print OUT "// (classId, name (index in methodNames), argumentList index, number of args, method flags, return type (index in types), xcall() index)\n";
#    print OUT "static Smoke::Method ${libname}_methods[] = {\n";
    my @methods;
    %allMethods = ();
    my $methodCount = 0;
    # Look at all classes and all enums again
    Iter::LocalCompounds( $rootnode, sub {
	my $classNode = shift;
	my $className = join( "::", kdocAstUtil::heritage($classNode) );
	return if $classNode->{NodeType} eq 'namespace';
	
	my $classIndex = $classidx{$className};
	print STDERR "writeSmokeDataFile: methods: looking at $className\n" if ($debug);

	Iter::MembersByType ( $classNode, undef,
		sub {	my ($classNode, $m ) = @_;

	if( $m->{NodeType} eq "enum" ) {

	    foreach my $enum ( @{$m->{ParamList}} ) {
		my $enumName = $enum->{ArgName};
		my $fullEnumName = "$className\::$enumName";
		my $sig = "$className\::$enumName\()";
		my $xmethIndex = $methodidx{$enumName};
		die "'Method index' for enum $sig not found" unless defined $xmethIndex;
		my $typeId = findTypeEntry( $fullEnumName )->{index};
		die "enum has no {case} value in $className: $fullEnumName" unless defined $classNode->{case}{$fullEnumName};
#		print OUT "    {$classIndex, $xmethIndex, 0, 0, Smoke::mf_static, $typeId, $classNode->{case}{$fullEnumName}},    //$methodCount $fullEnumName (enum)\n";
		$allMethods{$sig} = $methodCount;
		print STDERR "Added entry for " . $sig . " into \$allMethods\n" if ($debug);
		$methods[$methodCount] = {
				c => $classIndex,
				methIndex => $xmethIndex,
				argcnt => '0',
				args => 0,
				retTypeIndex => 0,
				idx => $classNode->{case}{$fullEnumName}
			       };
		$methodCount++;
	    }

	} elsif( $m->{NodeType} eq 'var' ) {

	    my $name = $m->{astNodeName};
	    my $fullName = "$className\::$name";
	    my $sig = "$fullName\()";
	    my $xmethIndex = $methodidx{$name};
	    die "'Method index' for var $sig not found" unless defined $xmethIndex;
	    my $varType = $m->{Type};
	    $varType =~ s/static\s//;
	    $varType =~ s/const\s+(.*)\s*&/$1/;
	    $varType =~ s/\s*$//;
	    my $typeId = findTypeEntry( $varType )->{index};
	    die "var has no {case} value in $className: $fullName" unless defined $classNode->{case}{$fullName};
#	    print OUT "    {$classIndex, $xmethIndex, 0, 0, Smoke::mf_static, $typeId, $classNode->{case}{$fullName}},    //$methodCount $fullName (static var)\n";
            $allMethods{$sig} = $methodCount;
	    print STDERR "Added entry for " . $sig . " into \$allMethods\n" if ($debug);
	    $methods[$methodCount] = {
				c => $classIndex,
				methIndex => $xmethIndex,
				argcnt => '0',
				args => 0,
				retTypeIndex => 0,
				idx => $classNode->{case}{$fullName}
			       };
	    $methodCount++;


	} elsif( $m->{NodeType} eq "method" ) {

	    # We generate a method entry only if the method is in the switch() code
	    # BUT: for pure virtuals, they need to have a method entry, even though they
	    # do NOT have a switch code.
	    return if ( $m->{SkipFromSwitch} && $m->{Flags} !~ "p" );

	    # No switch code for destructors if we didn't derive from the class (e.g. it has private ctors only)
    	    return if ( $m->{ReturnType} eq '~' && ! ( $classNode->{BindingDerives} and $classNode->{HasPublicDestructor}) );

            # Is this sorting really important?
	    #for my $m (sort {$a->{name} cmp $b->{name}} @{ $self->{$c}{method} }) {

	    my $methName = $m->{astNodeName};
	    my $def = $m->{FirstDefaultParam};
	    $def = scalar(@{ $m->{ParamList} }) unless defined $def;
	    my $last = scalar(@{ $m->{ParamList} }) - 1;
	    #print STDERR "writeSmokeDataFile: methods: generating for method $methName, def=$def last=$last\n" if ($debug);

	    while($last >= ($def-1)) {
		last if $last < -1;
		my $args = [ @{ $m->{ParamList} }[0..$last] ];
		my $sig = methodSignature($m, $last);
		#my $methodSig = $classNode->{signature}{$sig}; # Munged signature
		#print STDERR "writeSmokeDataFile: methods: sig=$className\::$sig methodSig=$methodSig\n" if ($debug);
		#my $methodIndex = $methodidx{$methodSig};
		#die "$methodSig" if !defined $methodIndex;

		my $methodIndex = $methodidx{$methName};
		die "$methName" if !defined $methodIndex;
		my $case = $classNode->{case}{$sig};
		my $typeEntry = findTypeEntry( $m->{ReturnType} );
		my $retTypeIndex = defined $typeEntry ? $typeEntry->{index} : 0;

		my $i = 0;
		my $t = '';
		for my $arg (@$args) {
		    $t .= ', ' if $i++;
		    my $typeEntry = findTypeEntry( $arg->{ArgType} );
		    $t .= defined $typeEntry ? $typeEntry->{index} : 0;
		}
		my $arglist = $t eq '' ? 0 : $arglist{$t};
		die "arglist for $t not found" unless defined $arglist;
		if ( $m->{Flags} =~ "p" ) {
		    # Pure virtuals don't have a {case} number, that's normal
		    die if defined $case;
		    $case = -1; # This remains -1, not 0 !
		} else {
			;
#		    die "$className\::$methName has no case number for sig=$sig" unless defined $case;
		}
		my $argcnt = $last + 1;
		my $methodFlags = '0';
		$methodFlags .= "|Smoke::mf_static" if $m->{Flags} =~ "s";
		$methodFlags .= "|Smoke::mf_const" if $m->{Flags} =~ "c"; # useful?? probably not
		$methodFlags =~ s/0\|//; # beautify
		
#		print OUT "    {$classIndex, $methodIndex, $arglist, $argcnt, $methodFlags, $retTypeIndex, $case},    //$methodCount $className\::$sig";
#		print OUT " [pure virtual]" if ( $m->{Flags} =~ "p" ); # explain why $case = -1 ;)
#		print OUT "\n";
		
		$allMethods{$className . "::" . $sig} = $methodCount;
		$methods[$methodCount] = {
					  c => $classIndex,
					  methIndex => $methodIndex,
					  argcnt => $argcnt,
					  args => $arglist,
					  retTypeIndex => $retTypeIndex,
					  idx => $case
					 };
		$methodCount++;
		$last--;
	    } # while
	} # if method
      } ); # Method Iter
    } ); # Class Iter
#    print OUT "};\n\n";

    my @protos;
    Iter::LocalCompounds( $rootnode, sub {
	my $classNode = shift;
	my $className = join( "::", kdocAstUtil::heritage($classNode) );
	
	return if $classNode->{NodeType} eq 'namespace';
	
	my $classIndex = $classidx{$className};
	print STDERR "writeSmokeDataFile: protos: looking at $className\n" if ($debug);

	Iter::MembersByType ( $classNode, undef,
		sub {	my ($classNode, $m ) = @_;

	if( $m->{NodeType} eq "enum" ) {
	    foreach my $enum ( @{$m->{ParamList}} ) {
		my $enumName = $enum->{ArgName};
		my $sig = "$className\::$enumName\()";
		my $xmeth = $allMethods{$sig};
		die "'Method' for enum $sig not found" unless defined $xmeth;
		my $xmethIndex = $methodidx{$enumName};
		die "'Method index' for enum $enumName not found" unless defined $xmethIndex;
		push @protos, {
			       methIndex => $xmethIndex,
			       c => $classIndex,
			       over => {
					$sig => {
						 sig => $sig,
						}
				       },
			       meth => $xmeth
			      };
	    }

	} elsif( $m->{NodeType} eq 'var' ) {

	    my $name = $m->{astNodeName};
	    my $fullName = "$className\::$name";
	    my $sig = "$fullName\()";
	    my $xmeth = $allMethods{$sig};
	    die "'Method' for var $sig not found" unless defined $xmeth;
	    my $xmethIndex = $methodidx{$name};
	    die "'Method index' for var $name not found" unless defined $xmethIndex;
	    push @protos, {
			       methIndex => $xmethIndex,
			       c => $classIndex,
			       over => {
					$sig => {
						 sig => $sig,
						}
				       },
			       meth => $xmeth
			  };

	}
		    });

	for my $p (keys %{ $classNode->{proto} }) {
	    # For each prototype
	    my $scratch = { %{ $classNode->{proto}{$p} } }; # sig->method association
	    # first, grab all the superclass voodoo
	    for my $supNode (superclass_list($classNode)) {
		my $i = $supNode->{proto}{$p};
		next unless $i;
		for my $k (keys %$i) {
		    $scratch->{$k} = $i->{$k} unless exists $scratch->{$k};
		}
	    }

	    # Ok, now we have a full list
	    #if(scalar keys %$scratch > 1) {
		#print STDERR "Overload: $p (@{[keys %$scratch]})\n" if ($debug);
	    #}
	    my $xmethIndex = $methodidx{$p};
	    my $classIndex = $classidx{$className};
	    for my $sig (keys %$scratch) {
		#my $xsig = $scratch->{$sig}{class} . "::" . $sig;
		my $xsig = $className . "::" . $sig;
		$scratch->{$sig}{sig} = $xsig;
		delete $scratch->{$sig}
		    if $scratch->{$sig}{Flags} =~ "p" # pure virtual
			or not exists $allMethods{$xsig};
	    }
	    push @protos, {
		methIndex => $xmethIndex,
		c => $classIndex,
		over => $scratch
	    } if scalar keys %$scratch;
	}
    });

    my @protolist = sort { $a->{c} <=> $b->{c} || $a->{methIndex} <=> $b->{methIndex} } @protos;
#for my $abc (@protos) {
#print "$abc->{methIndex}.$abc->{c}\n";
#}

    print STDERR "Writing methodmap table\n" if ($debug);
    my @resolve = ();
#    print OUT "// Class ID, munged name ID (index into methodNames), method def (see methods) if >0 or number of overloads if <0\n";
    my $methodMapCount = 1;
#    print OUT "static Smoke::MethodMap ${libname}_methodMaps[] = {\n";
#    print OUT "    { 0, 0, 0 },    //0 (no method)\n";
    for my $cur (@protolist) {
	if(scalar keys %{ $cur->{over} } > 1) {
#	    print OUT "    {$cur->{c}, $cur->{methIndex}, -@{[1+scalar @resolve]}},    //$methodMapCount $classlist[$cur->{c}]\::$methodlist[$cur->{methIndex}]\n";
	    $methodMapCount++;
	    for my $k (keys %{ $cur->{over} }) {
	        my $p = $cur->{over}{$k};
	        my $xsig = $p->{class} ? "$p->{class}\::$k" : $p->{sig};
	        push @resolve, { k => $k, p => $p, cur => $cur, id => $allMethods{$xsig} };
	    }
	    push @resolve, 0;
	} else {
	    for my $k (keys %{ $cur->{over} }) {
	        my $p = $cur->{over}{$k};
	        my $xsig = $p->{class} ? "$p->{class}\::$k" : $p->{sig};
#	        print OUT "    {$cur->{c}, $cur->{methIndex}, $allMethods{$xsig}},    //$methodMapCount $classlist[$cur->{c}]\::$methodlist[$cur->{methIndex}]\n";
	        $methodMapCount++;
	    }
	}
    }
#    print OUT "};\n\n";


    print STDERR "Writing ambiguousMethodList\n" if ($debug);
#    print OUT "static Smoke::Index ${libname}_ambiguousMethodList[] = {\n";
#    print OUT "    0,\n";
    for my $r (@resolve) {
	unless($r) {
#	    print OUT "    0,\n";
	    next;
	}
	my $xsig = $r->{p}{class} ? "$r->{p}{class}\::$r->{k}" : $r->{p}{sig};
	die "ambiguousMethodList: no method found for $xsig\n" if !defined $allMethods{$xsig};
#	print OUT "    $allMethods{$xsig},  // $xsig\n";
    }
#    print OUT "};\n\n";

#    print OUT "extern \"C\" { // needed?\n";
#    print OUT "    void init_${libname}_Smoke();\n";
#    print OUT "}\n";
#    print OUT "\n";
#    print OUT "Smoke* qt_Smoke = 0L;\n";
#    print OUT "\n";
#    print OUT "// Create the Smoke instance encapsulating all the above.\n";
#    print OUT "void init_${libname}_Smoke() {\n";
#    print OUT "    qt_Smoke = new Smoke(\n";
#    print OUT "        ${libname}_classes, ".$#classlist.",\n";
#    print OUT "        ${libname}_methods, $methodCount,\n";
#    print OUT "        ${libname}_methodMaps, $methodMapCount,\n";
#    print OUT "        ${libname}_methodNames, $methodNameCount,\n";
#    print OUT "        ${libname}_types, $typeCount,\n";
#    print OUT "        ${libname}_inheritanceList,\n";
#    print OUT "        ${libname}_argumentList,\n";
#    print OUT "        ${libname}_ambiguousMethodList,\n";
#    print OUT "        ${libname}_cast );\n";
#    print OUT "}\n";
#    close OUT;

#print "@{[keys %allMethods ]}\n";
}

sub indentText($$)
{
	my ( $indent, $text ) = @_;

	if ( $indent eq "" || $text eq "" ) {
		return $text;
	}

	$text =~ s/\n(.)/\n$indent$1/g;
	return $indent . $text;
}

=head2 printCSharpdocComment

	Parameters: docnode filehandle

	Converts a kdoc comment to csharpdoc format.
	@ref's are converted to <see>'s; @p's and @em's are converted
	to inline HTML.

=cut

sub printCSharpdocComment($$$$)
{
	my( $docnode, $name, $indent, $signalLink ) = @_;

	my $node;
	my $returntext = '<remarks>';
	foreach $node ( @{$docnode->{Text}} ) {
		next if $node->{NodeType} ne "DocText" and $node->{NodeType} ne "ListItem" 
		and $node->{NodeType} ne "Param";
		my $line = '';
		
		if ($node->{NodeType} eq "Param") {
			if ($node->{Name} !~ /argc/) {
				$line = "<param> name=\"" . $node->{Name} . "\" " . $node->{astNodeName} . "</param>";
			}
		} else {
			$line = $node->{astNodeName};
		}
		$line =~ s/argc, ?argv/args/g;
		$line =~ s/int argc, ?char ?\* ?argv(\[\])?/string[] args/g;
		$line =~ s/int argc, ?char ?\*\* ?argv/string[] args/g;
#		if ($node->{NodeType} eq "Param") {
#			$line =~ s/(const )?QC?StringList(\s*&)?/string[]/g;
#		} else {
			$line =~ s/(const )?QC?StringList(\s*&)?/List<string>/g;
#		}
		$line =~ s/NodeList/ArrayList/g;
		$line =~ s/KTrader::OfferList/ArrayList/g;
		$line =~ s/QString::null/null/g;
		$line =~ s/(const )?QC?String(\s*&)?/string/g;
		$line =~ s/KCmdLineLastOption//g;
		$line =~ s/virtual //g;
		$line =~ s/~\w+\(\)((\s*{\s*})|;)//g;
		$line =~ s/0L/null/g;
		$line =~ s/(\([^\)]*\))\s*:\s*\w+\([^\)]*\)/$1/g;
		$line =~ s/\(void\)//g;
		$line =~ s/const char/string/g;
		$line =~ s/const (\w+)\&/$1/g;
		$line =~ s/bool/bool/g;
		$line =~ s/SLOT\(\s*([^\)]*)\) ?\)/SLOT("$1)")/g;
		$line =~ s/SIGNAL\(\s*([^\)]*)\) ?\)/SIGNAL("$1)")/g;
		$line =~ s/Q_OBJECT\n//g;
		$line =~ s/public\s*(slots)?:\n/public /g;
		$line =~ s/([^0-9"]\s*)\*(\s*[^0-9"-])/$1$2/g;
		$line =~ s/^(\s*)\*/$1/g;
		$line =~ s/\n \*/\n /g;
		$line =~ s!\@ref\s+([\w]+)::([\w]+)\s*(\([^\)]*\))(\.)?!<see cref=\"$1#$2\"></see>$4!g;
		$line =~ s!\@ref\s+#([\w:]+)(\(\))?!<see cref=\"#$1\"</see>!g;
		$line =~ s!\@ref\s+([\w]+)\s*(\([^\)]*\))!<see cref=\"#$1\"></see>!g;
		$line =~ s!\@ref\s+([\w]+)::([\w]+)!<see cref=\"$1#$2\"></see>!g;
		$line =~ s!\@ref\s+([a-z][\w]+)!<see cref=\"#$1\"></see>!g;
		$line =~ s!\@ref\s+([\w]+)!<see cref=\"$1\"></see>!g;
		while ($line =~ /\@c\s+([\w#\\\.<>]+)/ ) {
			my $code = $1;
			$code =~ s!<!&lt;!g;
			$code =~ s!>!&gt;!g;
			$code =~ s!\\#!#!g;
			$line =~ s!\@c\s+([\w#\\\.<>]+)!<code>$code</code>!;
		}
		$line =~ s!\@em\s+(\w+)!<b>$1</b>!g;
		$line =~ s!\@p\s+([\w\._]*)!<code>$1</code>!g;
		$line =~ s!\\paragraph\s+[\w]+\s([\w]+)!<li><b>$1</b></li>!g;
		$line =~ s!\\b\s+([\w -]+)\\n!<li><b>$1</b></li>!g;
		$line =~ s!\\c\s+([\w\@&\\?;-]+)!<code>$1</code>!g;
		$line =~ s!\\p\s+([\w\@]+)!<pre>$1</pre>!g;
		$line =~ s!\\li\s+([\w\@]+)!<li>$1</li>!g;
		$line =~ s!<b>([\w     \(\)-]*:?)</b>\\n!<li><b>$1</b></li>!g;
		$line =~ s!static_cast<\s*([\w\.]*)\s*>!($1)!g;
#		if ($name ne "") {
#			$line =~ s/\@link #/\@link $name\#/g;
#		}
		
		if ($node->{NodeType} eq "ListItem") {
			$line =~ s/^/\n<li>\n/;
			$line =~ s!$!\n</li>!;
#			$line =~ s/\n/\n$indent    /g;
		} else {
#			$line =~ s/^/$indent/;
#			$line =~ s/\n/\n$indent/g;
		}
		
#		$line =~ s/\n/\n$indent/g;
		$returntext .= $line;
	}
	
	$returntext .= "$signalLink</remarks>";
	
	if ( defined $docnode->{Returns} ) {
		my $text = $docnode->{Returns};
		$text =~ s/QString::null/null/g;
		$returntext .=  "        <return> $text</return>\n";
	}
		
	if ( defined $docnode->{Author} ) { 
		$returntext .= "        <author> " . $docnode->{Author} . "</author>\n" 
	}
		
	if ( defined $docnode->{Version} ) {
		my $versionStr = $docnode->{Version};
		$versionStr =~ s/\$\s*Id:([^\$]*) Exp \$/$1/;
		$returntext .= "        <version> $versionStr</version>\n";
	}
		
	if ( defined $docnode->{ClassShort} ) { 
		my $shortText = $docnode->{ClassShort};
		$shortText =~ s![\*\n]! !g;
		$returntext .= "        <short> $shortText</short>\n";
	}
	
	if ( defined $docnode->{See} ) {
		foreach my $text ( @{$docnode->{See}} ) {
			next if ($text =~ /QString|^\s*and\s*$|^\s*$|^[^\w]*$/);
			$text =~ s/KIO:://g;
			$text =~ s/KParts:://g;
			while ($text =~ /((::)|(->))(.)/) {
				my $temp = uc($4);
				$text =~ s/$1$4/.$temp/;
			}
			$text =~ s/\(\)//g;
			$text =~ s/^\s*([a-z].*)/$1/g;
			$returntext .= "        <see> $text</see>\n";
		}
	}	

	$returntext =~ s!\\link!<see>!g;
	$returntext =~ s!\\endlink!</see>!g;
	$returntext =~ s/DOM#([A-Z])/$1/g;
	$returntext =~ s/KIO#([A-Z])/$1/g;
	$returntext =~ s/KParts#([A-Z])/$1/g;
	$returntext =~ s/const\s+(\w+)\s*\&/$1/g;
#	$returntext =~ s/QChar/char/g;
	$returntext =~ s/QStringList/List<string>/g;
	$returntext =~ s/([Aa]) ArrayList/$1n ArrayList/g;
	$returntext =~ s/QString/string/g;
	$returntext =~ s!\\note!<b>Note:<\b>!g;
	$returntext =~ s!\\(code|verbatim)!<pre>!g;
	$returntext =~ s!\\(endcode|endverbatim)!</pre>!g;
	$returntext =~ s!\\addtogroup\s+[\w]+\s+"([^"\@]+)"\s+\@{!<li><b>$1</b></li>!g;
	$returntext =~ s![\\\@]relates\s+([a-z][\w]*)!<see cref=\"$1\"></see>!g;
	$returntext =~ s![\\\@]relates\s+(\w+)::(\w+)!<see cref=\"$1.$2\"></see>!g;
	$returntext =~ s![\\\@]relates\s+(#?\w+)!<see cref=\"$1\"></see>!g;
	$returntext =~ s!\\c\s+([\w\@&\\?";-]+)!<code>$1</code>!g;
	$returntext =~ s!\@p\s+([\w\._]*)!<code>$1</code>!g;
	$returntext =~ s!\@a\s+([:\w]+)!<b>$1</b>!g;
	$returntext =~ s![\@\\]b\s+[:\w]!<b>$1</b>!g;
	$returntext =~ s/};/}/g;

	while ($returntext =~ /((::)|(->))(.)/) {
		my $temp = uc($4);
		$returntext =~ s/$1$4/.$temp/;
	}
	
	$returntext =~ s/\s*$//;
	if ($returntext =~ /^<remarks>\s*<\/remarks>$/) {
		return "";
	} else {
		$returntext =~ s/\n/\n$indent/g;
		$returntext =~ s/^/$indent/;
		return $returntext . "\n";
	}
}

1;
