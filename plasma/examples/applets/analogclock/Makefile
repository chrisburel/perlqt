all : Ui_ClockConfig.pm Ui_GeneralConfig.pm Ui_TimezonesConfig.pm Ui_CalendarConfig.pm

Ui_ClockConfig.pm : clockConfig.ui
	puic4 clockConfig.ui -o Ui_ClockConfig.pm

Ui_GeneralConfig.pm : generalConfig.ui
	puic4 generalConfig.ui -o Ui_GeneralConfig.pm

Ui_TimezonesConfig.pm : timezonesConfig.ui
	puic4 timezonesConfig.ui -o Ui_TimezonesConfig.pm

Ui_CalendarConfig.pm : calendarConfig.ui
	puic4 calendarConfig.ui -o Ui_CalendarConfig.pm

check :
	perl -c Ui_ClockConfig.pm
	perl -c Ui_GeneralConfig.pm
	perl -c Ui_TimezonesConfig.pm
	perl -c Ui_CalendarConfig.pm

clean :
	rm -f Ui_ClockConfig.pm Ui_GeneralConfig.pm Ui_TimezonesConfig.pm Ui_CalendarConfig.pm
