# OSX script to create SWC and .zxp files

###############################################################
###############################################################
#Setup vars
###############################################################
###############################################################

#Adobe Extension Manager CS5.5 executable location
EXTENSION_MANAGER=/Applications/Adobe\ Extension\ Manager\ CS5.5/Adobe\ Extension\ Manager\ CS5.5.app/Contents/MacOS/Adobe\ Extension\ Manager\ CS5.5

#Flex sdk locations
FLEX_3=<PATH_TO_FLE_3>/
FLEX_4=<PATH_TO_FLE_4>/

if [ ! -d "$FLEX_3" ]
then
	echo "Flex 3 SDK not found!";
	exit;
fi

if [ ! -d "$FLEX_4" ]
then
	echo "Flex 4 SDK not found!";
	exit;
fi

#Export locations for the Flex swc files.
FLEX_3_SWC="Flex/SPL2Flex3x_TextField.swc"
FLEX_4_SWC="Flex/SPL2Flex4x_TLF.swc"

###############################################################
###############################################################
#Setup some functions
###############################################################
###############################################################
exportFlex3 () {
	#Export the Flex 3 swc
	"${FLEX_3}bin/compc" -compiler.external-library-path="${FLEX_3}/frameworks/libs/"  -compiler.external-library-path+="${FLEX_3}/frameworks/libs/player/10/playerglobal.swc" -warnings=false -source-path="Flex/TextField Support/" -source-path+="../source/" -include-classes= "com.gskinner.text.PluginFactoryDefaults" "com.gskinner.spelling.CustomWordListLSO" "com.gskinner.spelling.ISpellingHighlighterPlugin" "com.gskinner.spelling.SPLCustomWordListLSO" "com.gskinner.spelling.SPLCustomWordListLSOFlex" "com.gskinner.spelling.SPLTag" "com.gskinner.spelling.SPLTagFlex" "com.gskinner.spelling.SPLWordListLoader" "com.gskinner.spelling.SPLWordListLoaderFlex" "com.gskinner.spelling.SpellingDictionary" "com.gskinner.spelling.SpellingDictionaryEvent" "com.gskinner.spelling.SpellingHighlighter" "com.gskinner.spelling.SpellingTextFieldPlugin" "com.gskinner.spelling.SpellingTextFieldPluginFactory" "com.gskinner.spelling.SpellingUtils" "com.gskinner.spelling.WordListLoader" "com.gskinner.spelling.ui.AbstractSpellingUIPlugin" "com.gskinner.spelling.ui.ContextMenuData" "com.gskinner.spelling.ui.ContextMenuPlugin" "com.gskinner.spelling.ui.MobileContextMenu" "com.gskinner.spelling.ui.MobileContextMenuPlugin" "com.gskinner.spelling.ui.SPLComponent" "com.gskinner.spelling.ui.SPLContextMenuEvent" "com.gskinner.spelling.ui.SPLContextMenuItem" "com.gskinner.spelling.ui.SPLContextMenuItemRenderer" "com.gskinner.spelling.ui.SPLContextMenuItemSeparator" "com.gskinner.text.CharacterSet" "com.gskinner.text.ITextHighlighterPlugin" "com.gskinner.text.ITextHighlighterPluginFactory" "com.gskinner.text.PluginFactoryDefaults" "com.gskinner.text.StringPosition" "com.gskinner.text.TextFieldPlugin" "com.gskinner.text.TextFieldPluginFactory" "com.gskinner.text.TextHighlighter" "com.gskinner.text.TextUtils" -output $FLEX_3_SWC ;
}

exportFlex4 () {
	#Export the Flex 4.0 swc
	"${FLEX_4}bin/compc" -compiler.external-library-path="${FLEX_4}/frameworks/libs/"  -compiler.external-library-path+="${FLEX_4}/frameworks/libs/player/10.2/playerglobal.swc" -warnings=false -source-path="Flex/TLF Support/" -source-path+="../source/" -include-classes= "com.gskinner.text.PluginFactoryDefaults" "com.gskinner.spelling.CustomWordListLSO" "com.gskinner.spelling.ISpellingHighlighterPlugin" "com.gskinner.spelling.SPLCustomWordListLSO" "com.gskinner.spelling.SPLCustomWordListLSOFlex" "com.gskinner.spelling.SPLTag" "com.gskinner.spelling.SPLTagFlex" "com.gskinner.spelling.SPLWordListLoader" "com.gskinner.spelling.SPLWordListLoaderFlex" "com.gskinner.spelling.SpellingDictionary" "com.gskinner.spelling.SpellingDictionaryEvent" "com.gskinner.spelling.SpellingHighlighter" "com.gskinner.spelling.SpellingRichEditableTextPlugin" "com.gskinner.spelling.SpellingRichEditableTextPluginFactory" "com.gskinner.spelling.SpellingTextFieldPlugin" "com.gskinner.spelling.SpellingTextFieldPluginFactory" "com.gskinner.spelling.SpellingUtils" "com.gskinner.spelling.WordListLoader" "com.gskinner.spelling.ui.AbstractSpellingUIPlugin" "com.gskinner.spelling.ui.ContextMenuData" "com.gskinner.spelling.ui.ContextMenuPlugin" "com.gskinner.spelling.ui.MobileContextMenu" "com.gskinner.spelling.ui.MobileContextMenuPlugin" "com.gskinner.spelling.ui.SPLComponent" "com.gskinner.spelling.ui.SPLContextMenuEvent" "com.gskinner.spelling.ui.SPLContextMenuItem" "com.gskinner.spelling.ui.SPLContextMenuItemRenderer" "com.gskinner.spelling.ui.SPLContextMenuItemSeparator" "com.gskinner.text.CharacterSet" "com.gskinner.text.ITextHighlighterPlugin" "com.gskinner.text.ITextHighlighterPluginFactory" "com.gskinner.text.PluginFactoryDefaults" "com.gskinner.text.RichEditableTextPlugin" "com.gskinner.text.RichEditableTextPluginFactory" "com.gskinner.text.StringPosition" "com.gskinner.text.TextFieldPlugin" "com.gskinner.text.TextFieldPluginFactory" "com.gskinner.text.TextHighlighter" "com.gskinner.text.TextUtils" -output $FLEX_4_SWC ;
}

#Exports the Flex swc files
exportFlex3
exportFlex4

#Creating the MXP files take some time, so we make optional.
read -n1 -p "Do you wish to re-create the MXP files? (Make sure you run BuildSWC.jsfl first!) y/n? " result

if [[ $result = "y" || $result = "Y" ]] ; then
		
		if [ ! -f "$EXTENSION_MANAGER" ]
		then
			echo "Adobe Extension manager not found.";
			exit;
		fi
		
		echo " Creating MXP and ZXP files for Flash. Close the Extension manager after each creation"
		
		#Package Spelling Plus Library CS3.mxp
		"${EXTENSION_MANAGER}" -package mxi="Flash/build/Spelling Plus Library CS3.mxi" mxp="Flash/build/Spelling Plus Library CS3.mxp"
		
		#Package Spelling Plus Library CS5.mxp
		"${EXTENSION_MANAGER}" -package mxi="Flash/build/Spelling Plus Library CS5.mxi" zxp="Flash/build/Spelling Plus Library CS5.zxp"
		
		#Package Spelling Plus Library CS5.5.mxp
		"${EXTENSION_MANAGER}" -package mxi="Flash/build/Spelling Plus Library CS5.5.mxi" zxp="Flash/build/Spelling Plus Library CS5.5.zxp"
fi

echo "-- DONE --"