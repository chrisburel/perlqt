all : Ui_MainWindow.pm Ui_StyleSheetEditor.pm

Ui_MainWindow.pm : mainwindow.ui /pts/testPipe/share/Qt4/def/dat/perlqt4/build/perl/tools/puic/puic4
	puic4 mainwindow.ui -o Ui_MainWindow.pm

Ui_StyleSheetEditor.pm : stylesheeteditor.ui /pts/testPipe/share/Qt4/def/dat/perlqt4/build/perl/tools/puic/puic4
	puic4 stylesheeteditor.ui -o Ui_StyleSheetEditor.pm

clean :
	rm Ui_StyleSheetEditor.pm Ui_MainWindow.pm
