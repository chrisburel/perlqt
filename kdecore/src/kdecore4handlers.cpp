/***************************************************************************
                          kdecore4handlers.cpp  -  KDECore specific marshallers
                             -------------------
    begin                : 03-29-2010
    copyright            : (C) 2010 Chris Burel
    email                : chrisburel@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either veqtruby_project_template.rbrsion 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

//#include <QtTest/qtestaccessible.h>

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
}

#include <smokeperl.h>
#include <marshall_macros.h>

#include <kservice.h>
#include <kaction.h>
#include <kactioncollection.h>
#include <kautosavefile.h>
#include <kconfigdialogmanager.h>
#include <kjob.h>
#include <kmainwindow.h>
#include <kplotobject.h>
#include <kplotpoint.h>
#include <ktoolbar.h>
#include <kxmlguiclient.h>


#include <kaboutdata.h>
#include <kcoreconfigskeleton.h>
#include <kfileitem.h>
#include <kplugininfo.h>
#include <kserviceaction.h>
#include <kservicegroup.h>
#include <ktimezone.h>
#include <kurl.h>
#include <KUserGroup>
#include <kuser.h>
#include <QColor>

void marshall_KServiceList(Marshall *m) {
    switch(m->action()) {
        case Marshall::FromSV: 
            {
            }
            break;
        case Marshall::ToSV: {
            KService::List *offerList = (KService::List*)m->item().s_voidp;
            if (!offerList) {
                sv_setsv(m->var(), &PL_sv_undef);
                break;
            }

            AV* av = newAV();
            SV* avref = newRV_noinc((SV*)av);

            Smoke::ModuleIndex mi = Smoke::findClass("KService");

            for (   KService::List::Iterator it = offerList->begin();
                    it != offerList->end();
                    ++it ) 
            {
                KSharedPtr<KService> *ptr = new KSharedPtr<KService>(*it);
                KService * currentOffer = ptr->data();

                SV* obj = getPointerObject(currentOffer);
                if (!obj || !SvOK(obj)) {
                    smokeperl_object * o = alloc_smokeperl_object(
                        false, mi.smoke, mi.index, currentOffer );
                    const char* classname = perlqt_modules[o->smoke].resolve_classname(o);

                    obj = set_obj_info( classname, o );
                }
                else {
                    // See comment in marshall_macros.h
                    obj = newRV_inc(SvRV(obj));
                }
                av_push(av, obj);
            }

            sv_setsv(m->var(), avref);            

            if (m->cleanup())
                delete offerList;
        }
            break;
        default:
            m->unsupported();
            break;
    }
}

DEF_LIST_MARSHALLER( KActionList, QList<KAction*>, KAction )
DEF_LIST_MARSHALLER( KActionCollectionList, QList<KActionCollection*>, KActionCollection )
DEF_LIST_MARSHALLER( KAutoSaveFileList, QList<KAutoSaveFile*>, KAutoSaveFile )
DEF_LIST_MARSHALLER( KConfigDialogManagerList, QList<KConfigDialogManager*>, KConfigDialogManager )
DEF_LIST_MARSHALLER( KJobList, QList<KJob*>, KJob )
DEF_LIST_MARSHALLER( KMainWindowList, QList<KMainWindow*>, KMainWindow )
//DEF_LIST_MARSHALLER( KMultiTabBarButtonList, QList<KMultiTabBarButton*>, KMultiTabBarButton )
//DEF_LIST_MARSHALLER( KMultiTabBarTabList, QList<KMultiTabBarTab*>, KMultiTabBarTab )
//DEF_LIST_MARSHALLER( KNSEntryList, QList<KNS::Entry*>, KNS::Entry )
DEF_LIST_MARSHALLER( KPartsPartList, QList<KParts::Part*>, KParts::Part )
//DEF_LIST_MARSHALLER( KPartsPluginList, QList<KParts::Plugin*>, KParts::Plugin )
//DEF_LIST_MARSHALLER( KPartsReadOnlyPartList, QList<KParts::ReadOnlyPart*>, KParts::ReadOnlyPart )
DEF_LIST_MARSHALLER( KPlotObjectList, QList<KPlotObject*>, KPlotObject )
DEF_LIST_MARSHALLER( KPlotPointList, QList<KPlotPoint*>, KPlotPoint )
DEF_LIST_MARSHALLER( KToolBarList, QList<KToolBar*>, KToolBar )
DEF_LIST_MARSHALLER( KXMLGUIClientList, QList<KXMLGUIClient*>, KXMLGUIClient )


DEF_VALUELIST_MARSHALLER( KAboutLicenseList, QList<KAboutLicense>, KAboutLicense )
DEF_VALUELIST_MARSHALLER( KAboutPersonList, QList<KAboutPerson>, KAboutPerson )
DEF_VALUELIST_MARSHALLER( KCoreConfigSkeletonItemEnumChoiceList, QList<KCoreConfigSkeleton::ItemEnum::Choice>, KCoreConfigSkeleton::ItemEnum::Choice )
//DEF_VALUELIST_MARSHALLER( KDataToolInfoList, QList<KDataToolInfo>, KDataToolInfo )
//DEF_VALUELIST_MARSHALLER( KFileItemList, QList<KFileItem>, KFileItem )
//DEF_VALUELIST_MARSHALLER( KIOCopyInfoList, QList<KIO::CopyInfo>, KIO::CopyInfo )
//DEF_VALUELIST_MARSHALLER( KPartsPluginPluginInfoList, QList<KParts::Plugin::PluginInfo>, KParts::Plugin::PluginInfo )
DEF_VALUELIST_MARSHALLER( KPluginInfoList, QList<KPluginInfo>, KPluginInfo )
DEF_VALUELIST_MARSHALLER( KServiceActionList, QList<KServiceAction>, KServiceAction )
DEF_VALUELIST_MARSHALLER( KServiceGroupPtrList, QList<KServiceGroup::Ptr>, KServiceGroup::Ptr )
DEF_VALUELIST_MARSHALLER( KTimeZoneLeapSecondsList, QList<KTimeZone::LeapSeconds>, KTimeZone::LeapSeconds )
DEF_VALUELIST_MARSHALLER( KTimeZonePhaseList, QList<KTimeZone::Phase>, KTimeZone::Phase )
DEF_VALUELIST_MARSHALLER( KTimeZoneTransitionList, QList<KTimeZone::Transition>, KTimeZone::Transition )
DEF_VALUELIST_MARSHALLER( KUrlList, QList<KUrl>, KUrl )
DEF_VALUELIST_MARSHALLER( KUserGroupList, QList<KUserGroup>, KUserGroup )
DEF_VALUELIST_MARSHALLER( KUserList, QList<KUser>, KUser )
DEF_VALUELIST_MARSHALLER( QColorList, QList<QColor>, QColor )
//DEF_VALUELIST_MARSHALLER( KIOUDSEntryList, QList<KIO::UDSEntry>, KIO::UDSEntry )

TypeHandler KDECore4_handlers[] = {
    //{ "KFileItemList", marshall_KFileItemList },
    //{ "KFileItemList*", marshall_KFileItemList },
    //{ "KFileItemList&", marshall_KFileItemList },
    //{ "KNS::Entry::List", marshall_KNSEntryList },
    { "KPluginInfo::List", marshall_KPluginInfoList },
    { "KPluginInfo::List&", marshall_KPluginInfoList },
    { "KService::List", marshall_KServiceList },
    { "QList<KService::Ptr>", marshall_KServiceList },
    { "QList<KSharedPtr<KService> >", marshall_KServiceList },
    //{ "KService::Ptr", marshall_KServicePtr },
    //{ "KSharedConfig::Ptr", marshall_KSharedConfigPtr },
    //{ "KSharedConfig::Ptr&", marshall_KSharedConfigPtr },
    //{ "KSharedConfigPtr", marshall_KSharedConfigPtr },
    //{ "KSharedConfigPtr&", marshall_KSharedConfigPtr },
    //{ "KMimeType::Ptr", marshall_KSharedMimeTypePtr },
    //{ "KSharedPtr<KMimeType>", marshall_KSharedMimeTypePtr },
    //{ "KSharedPtr<KSharedConfig>", marshall_KSharedConfigPtr },
    //{ "KSharedPtr<KSharedConfig>&", marshall_KSharedConfigPtr },
    { "KUrl::List", marshall_KUrlList },
    { "KUrl::List&", marshall_KUrlList },
    { "KUrlList", marshall_KUrlList },
    { "KUrlList&", marshall_KUrlList },
    { "QList<KAboutLicense>", marshall_KAboutLicenseList },
    { "QList<KAboutPerson>", marshall_KAboutPersonList },
    { "QList<KActionCollection*>&", marshall_KActionCollectionList },
    { "QList<KAction*>", marshall_KActionList },
    { "QList<KAutoSaveFile*>", marshall_KAutoSaveFileList },
//    { "QList<KCatalogName>&", marshall_KCatalogNameList },
    { "QList<KConfigDialogManager*>", marshall_KConfigDialogManagerList },
    { "QList<KCoreConfigSkeleton::ItemEnum::Choice>", marshall_KCoreConfigSkeletonItemEnumChoiceList },
    { "QList<KCoreConfigSkeleton::ItemEnum::Choice>&", marshall_KCoreConfigSkeletonItemEnumChoiceList },
    //{ "QList<KDataToolInfo>", marshall_KDataToolInfoList },
    //{ "QList<KDataToolInfo>&", marshall_KDataToolInfoList },
    //{ "QList<KFileItem>&", marshall_KFileItemList },
    //{ "QList<KIO::CopyInfo>&", marshall_KIOCopyInfoList },
    { "QList<KJob*>&", marshall_KJobList },
    { "QList<KMainWindow*>", marshall_KMainWindowList },
    { "QList<KMainWindow*>&", marshall_KMainWindowList },
    //{ "QList<KMultiTabBarButton*>", marshall_KMultiTabBarButtonList },
    //{ "QList<KMultiTabBarTab*>", marshall_KMultiTabBarTabList },
    { "QList<KParts::Part*>", marshall_KPartsPartList },
    //{ "QList<KParts::Plugin*>", marshall_KPartsPluginList },
    //{ "QList<KParts::Plugin::PluginInfo>", marshall_KPartsPluginPluginInfoList },
    //{ "QList<KParts::Plugin::PluginInfo>&", marshall_KPartsPluginPluginInfoList },
    //{ "QList<KParts::ReadOnlyPart*>", marshall_KPartsReadOnlyPartList },
    { "QList<KPlotObject*>", marshall_KPlotObjectList },
    { "QList<KPlotObject*>&", marshall_KPlotObjectList },
    { "QList<KPlotPoint*>", marshall_KPlotPointList },
    { "QList<KPluginInfo>", marshall_KPluginInfoList },
    { "QList<KPluginInfo>&", marshall_KPluginInfoList },
    { "QList<KServiceAction>", marshall_KServiceActionList },
    { "QList<KServiceGroup::Ptr>", marshall_KServiceGroupPtrList },
    { "QList<KTimeZone::LeapSeconds>", marshall_KTimeZoneLeapSecondsList },
    { "QList<KTimeZone::LeapSeconds>&", marshall_KTimeZoneLeapSecondsList },
    { "QList<KTimeZone::Phase>", marshall_KTimeZonePhaseList },
    { "QList<KTimeZone::Phase>&", marshall_KTimeZonePhaseList },
    { "QList<KTimeZone::Transition>", marshall_KTimeZoneTransitionList },
    { "QList<KTimeZone::Transition>&", marshall_KTimeZoneTransitionList },
    { "QList<KToolBar*>", marshall_KToolBarList },
    { "QList<KUrl>", marshall_KUrlList },
    { "QList<KUserGroup>", marshall_KUserGroupList },
    { "QList<KUser>", marshall_KUserList },
    { "QList<KUser>&", marshall_KUserList },
    { "QList<KXMLGUIClient*>", marshall_KXMLGUIClientList },
    { "QList<KXMLGUIClient*>&", marshall_KXMLGUIClientList },
    { "QList<QColor>", marshall_QColorList },
    { "QList<QColor>&", marshall_QColorList },
    //{ "QList<KIO::UDSEntry>&", marshall_KIOUDSEntryList },
    //{ "KIO::UDSEntryList&", marshall_KIOUDSEntryList },
    //{ "QMap<QString,KTimeZone>", marshall_QMapQStringKTimeZone },
    { 0, 0 }
};
