//  MIJSONConstants.m
//  MovingImages
//
//  Copyright (c) 2015 Zukini Ltd.

#import "MIJSONConstants.h"

#pragma mark - draw element related option keys and values.

NSString *const MIJSONKeyElementDebugName = @"elementdebugname";

// The different type of elements.
NSString *const MIJSONKeyElementType = @"elementtype";

NSString *const MIJSONValueArrayOfElements = @"arrayofelements";
NSString *const MIJSONValueRectangleFillElement = @"fillrectangle";
NSString *const MIJSONValueRectangleStrokeElement = @"strokerectangle";
NSString *const MIJSONValueOvalFillElement = @"filloval";
NSString *const MIJSONValueOvalStrokeElement = @"strokeoval";
NSString *const MIJSONValueLineElement = @"drawline";
NSString *const MIJSONValueLineElements = @"drawlines";
NSString *const MIJSONValueRoundedRectangleFillElement =
                                                        @"fillroundedrectangle";
NSString *const MIJSONValueRoundedRectangleStrokeElement =
                                                    @"strokeroundedrectangle";
NSString *const MIJSONValuePathFillElement = @"fillpath";
NSString *const MIJSONValuePathStrokeElement = @"strokepath";
NSString *const MIJSONValuePathFillAndStrokeElement = @"fillandstrokepath";
NSString *const MIJSONValueBasicStringElement = @"drawbasicstring";
NSString *const MIJSONValueLinearGradientFill = @"lineargradientfill";
NSString *const MIJSONValueRadialGradientFill = @"radialgradientfill";
NSString *const MIJSONValueDrawImage = @"drawimage";
NSString *const MIJSONValuePathFillInnerShadowElement = @"fillinnershadowpath";

// The different type of elements that make up a path.

NSString *const MIJSONValuePathMoveTo = @"pathmoveto"; // { point }
NSString *const MIJSONValuePathLine = @"pathlineto"; // { endpoint }
NSString *const MIJSONValuePathBezierCurve = @"pathbeziercurve";
NSString *const MIJSONValuePathQuadraticCurve = @"pathquadraticcurve";
NSString *const MIJSONValuePathRectangle = @"pathrectangle"; // { rect }
NSString *const MIJSONValuePathRoundedRectangle = @"pathroundedrectangle";
NSString *const MIJSONValuePathOval = @"pathoval"; // { rect }
NSString *const MIJSONValuePathArc = @"patharc";
NSString *const MIJSONValuePathAddArcToPoint = @"pathaddarctopoint";
NSString *const MIJSONValueCloseSubPath = @"pathclosesubpath"; // nil

// More element types to go here.

NSString *const MIJSONKeyArrayOfElements = @"arrayofelements";

// Other top level keys for drawing instructions.

NSString *const MIJSONKeyVariablesDictionary = @"variables";

// Specific path related keys

NSString *const MIJSONKeyArrayOfPathElements = @"arrayofpathelements";
NSString *const MIJSONKeySVGPath = @"svgpath";

// Color related keys.

// NSString *const MIJSONKeyColor = @"color"; //{colorcolorprofilename,{red,...}}
NSString *const MIJSONKeyFillColor = @"fillcolor"; // color
NSString *const MIJSONKeyStrokeColor = @"strokecolor"; // color
NSString *const MIJSONKeyRed = @"red"; // CGFloat
NSString *const MIJSONKeyGreen = @"green"; // CGFloat
NSString *const MIJSONKeyBlue = @"blue"; // CGFloat
NSString *const MIJSONKeyGray = @"gray"; // CGFloat
NSString *const MIJSONKeyAlpha = @"alpha"; // CGFloat
NSString *const MIJSONKeyCyan = @"cyan"; // CGFloat
NSString *const MIJSONKeyMagenta = @"magenta"; // CGFloat
NSString *const MIJSONKeyYellow = @"yellow"; // CGFloat
NSString *const MIJSONKeyCMYKBlack = @"cmykblack"; // CGFloat
NSString *const MIJSONKeyColorColorProfileName = @"colorcolorprofilename"; //str
NSString *const MIJSONKeyArrayOfColors = @"arrayofcolors"; // colors

// Specific string related keys.

NSString *const MIJSONKeyStringText = @"stringtext"; // str
NSString *const MIJSONKeyStringPostscriptFontName = @"postscriptfontname"; // str
NSString *const MIJSONKeyStringFontSize = @"fontsize"; // float
NSString *const MIJSONKeyStringStrokeWidth = @"stringstrokewidth"; // float
NSString *const MIJSONKeyStringTextSubstitution = @"textsubstitution"; // str.

/*
 Geometry related keys.
*/

NSString *const MIJSONKeyRect = @"rect"; // { origin, size }
NSString *const MIJSONKeySize = @"size"; // { height, width }
NSString *const MIJSONKeyHeight = @"height"; // float
NSString *const MIJSONKeyWidth = @"width"; // float
NSString *const MIJSONKeyOrigin = @"origin"; // { x, y }
NSString *const MIJSONKeyPoint = @"point"; // { x, y }
NSString *const MIJSONKeyLine = @"line"; // { startpoint, endpoint }
NSString *const MIJSONKeyPoints = @"points"; // { arrayofpoints }
NSString *const MIJSONKeyStartPoint = @"startpoint"; // { x, y }
NSString *const MIJSONKeyEndPoint = @"endpoint"; // { x, y }
NSString *const MIJSONKeyCenterPoint = @"centerpoint"; // { x, y }
NSString *const MIJSONKeyCenterPoint2 = @"centerpoint2"; // { x, y }
NSString *const MIJSONKeyStartAngle = @"startangle"; // float in radians
NSString *const MIJSONKeyEndAngle = @"endangle"; // float in radians
NSString *const MIJSONKeyDrawArcClockwise = @"clockwise"; // { BOOL }
NSString *const MIJSONKeyControlPoint1 = @"controlpoint1"; // { x, y }
NSString *const MIJSONKeyControlPoint2 = @"controlpoint2"; // { x, y }
NSString *const MIJSONKeyTangentPoint1 = @"tangentpoint1"; // { x, y }
NSString *const MIJSONKeyTangentPoint2 = @"tangentpoint2"; // { x, y }
NSString *const MIJSONKeyX = @"x"; // float
NSString *const MIJSONKeyY = @"y"; // float
NSString *const MIJSONKeyRadius = @"radius"; // float
NSString *const MIJSONKeyRadius2 = @"radius2"; // float
NSString *const MIJSONKeyRadiuses = @"radiuses"; // Array of float. [float]
NSString *const MIJSONKeyLineCap = @"linecap"; // str enum
NSString *const MIJSONKeyLineJoin = @"linejoin"; // str enum
NSString *const MIJSONKeyContextAlpha = @"contextalpha"; // float
NSString *const MIJSONKeyGradientDrawOptions = @"gradientoptions"; // array str
NSString *const MIJSONKeyLineWidth = @"linewidth"; // float
NSString *const MIJSONKeyMiter = @"miter"; // str enum
NSString *const MIJSONKeyShadow = @"shadow"; // dictionary
NSString *const MIJSONKeyInnerShadow = @"innershadow"; // dictionary.
NSString *const MIJSONKeyClippingpath = @"clippingpath"; // dictionary.
NSString *const MIJSONKeyLineDashArray = @"dasharray"; // array of CGFloat.
NSString *const MIJSONKeyLineDashPhase = @"dashphase"; // CGFloat.
NSString *const MIJSONKeyApplyImageMask = @"applyimagemask"; // dictionary.
NSString *const MIJSONKeyShadowOffset = @"offset"; // { width, height }
NSString *const MIJSONKeyBlur = @"blur"; // float.
NSString *const MIJSONKeyClippingRule = @"clippingrule"; // str.

NSString *const MIJSONKeySourceRectangle = @"sourcerectangle"; // {origin, size}
NSString *const MIJSONKeyDestinationRectangle = @"destinationrectangle";

NSString *const MIJSONKeyArrayOfLocations = @"arrayoflocations"; // [float]

// NSString *const MIJSONKeyAlpha = @"alpha"; // { CGFloat 0..1 }
NSString *const MIJSONKeyBlendMode = @"blendmode"; // { enum of blend modes }
NSString *const MIJSONKeyInterpolationQuality = @"interpolationquality";

// MIJSONKeyContextTransformation is an array of translation, scaling, rotation.
// Each item in the array is a dictionary with a key MIJSONKeyTransformationType
// and its value can be one of: MIJSONValueTranslation, MIJSONValueScale,
// MIJSONValueRotation.
NSString *const MIJSONKeyContextTransformation = @"contexttransformation";
NSString *const MIJSONKeyTransformationType = @"transformationtype";

NSString *const MIJSONKeyAffineTransform = @"affinetransform";//{m11,m12,m21,m22,tx,ty}
NSString *const MIJSONKeyTranslation = @"translation"; // { x, y}
NSString *const MIJSONKeyScale = @"scale";
NSString *const MIJSONKeyRotation = @"rotation";

NSString *const MIJSONValueTranslate = @"translate"; // { x, y }
NSString *const MIJSONValueScale = @"scale"; // { x, y }
NSString *const MIJSONValueRotate = @"rotate"; // { angle (radians) }

NSString *const MIJSONKeyAffineTransformM11 = @"m11";
NSString *const MIJSONKeyAffineTransformM12 = @"m12";
NSString *const MIJSONKeyAffineTransformM21 = @"m21";
NSString *const MIJSONKeyAffineTransformM22 = @"m22";
NSString *const MIJSONKeyAffineTransformtX = @"tX";
NSString *const MIJSONKeyAffineTransformtY = @"tY";

/*
 Geometry values associated with various keys.
*/

// Values related to key MIJSONKeyLineCap.
NSString *const MIJSONValueLineCapButt = @"kCGLineCapButt";
NSString *const MIJSONValueLineCapRound = @"kCGLineCapRound";
NSString *const MIJSONValueLineCapSquare = @"kCGLineCapSquare";

// Values related to key MIJSONKeyLineJoin.
NSString *const MIJSONValueLineJoinMiter = @"kCGLineJoinMiter";
NSString *const MIJSONValueLineJoinRound = @"kCGLineJoinRound";
NSString *const MIJSONValueLineJoinBevel = @"kCGLineJoinBevel";

// Values for enum type CGGradientDrawingOptions for radial gradients.
NSString *const MIJSONValueGradientDrawBeforeStart =
                                        @"kCGGradientDrawsBeforeStartLocation";
NSString *const MIJSONValueGradientDrawAfterEnd =
                                        @"kCGGradientDrawsAfterEndLocation";

// Values related to the key MIJSONKeyClippingRule.
NSString *const MIJSONValueEvenOddClippingRule = @"evenoddrule";
NSString *const MIJSONValueNonWindowRule = @"nonwindingrule";

// Values related to key MIJSONKeyBlendMode

NSString *const MIJSONValueBlendModeNormal = @"kCGBlendModeNormal";
NSString *const MIJSONValueBlendModeMultiply = @"kCGBlendModeMultiply";
NSString *const MIJSONValueBlendModeScreen = @"kCGBlendModeScreen";
NSString *const MIJSONValueBlendModeOverlay = @"kCGBlendModeOverlay";
NSString *const MIJSONValueBlendModeDarken = @"kCGBlendModeDarken";
NSString *const MIJSONValueBlendModeLighten = @"kCGBlendModeLighten";
NSString *const MIJSONValueBlendModeColorDodge = @"kCGBlendModeColorDodge";
NSString *const MIJSONValueBlendModeColorBurn = @"kCGBlendModeColorBurn";
NSString *const MIJSONValueBlendModeSoftLight = @"kCGBlendModeSoftLight";
NSString *const MIJSONValueBlendModeHardLight = @"kCGBlendModeHardLight";
NSString *const MIJSONValueBlendModeDifference = @"kCGBlendModeDifference";
NSString *const MIJSONValueBlendModeExclusion = @"kCGBlendModeExclusion";
NSString *const MIJSONValueBlendModeHue = @"kCGBlendModeHue";
NSString *const MIJSONValueBlendModeSaturation = @"kCGBlendModeSaturation";
NSString *const MIJSONValueBlendModeColor = @"kCGBlendModeColor";
NSString *const MIJSONValueBlendModeLuminosity = @"kCGBlendModeLuminosity";
NSString *const MIJSONValueBlendModeClear = @"kCGBlendModeClear";
NSString *const MIJSONValueBlendModeCopy = @"kCGBlendModeCopy";
NSString *const MIJSONValueBlendModeSourceIn = @"kCGBlendModeSourceIn";
NSString *const MIJSONValueBlendModeSourceOut = @"kCGBlendModeSourceOut";
NSString *const MIJSONValueBlendModeSourceAtop = @"kCGBlendModeSourceAtop";
NSString *const MIJSONValueBlendModeDestinationOver =
                                                @"kCGBlendModeDestinationOver";
NSString *const MIJSONValueBlendModeDestinationIn =
                                                @"kCGBlendModeDestinationIn";
NSString *const MIJSONValueBlendModeDestinationOut =
                                                @"kCGBlendModeDestinationOut";
NSString *const MIJSONValueBlendModeDestinationAtop =
                                                @"kCGBlendModeDestinationAtop";
NSString *const MIJSONValueBlendModeXOR = @"kCGBlendModeXOR";
NSString *const MIJSONValueBlendModePlusDarker = @"kCGBlendModePlusDarker";
NSString *const MIJSONValueBlendModePlusLighter = @"kCGBlendModePlusLighter";

// Key and values related to the interpolation quality.

NSString *const MIJSONValueInterpolationDefault = @"kCGInterpolationDefault";
NSString *const MIJSONValueInterpolationNone = @"kCGInterpolationNone";
NSString *const MIJSONValueInterpolationLow = @"kCGInterpolationLow";
NSString *const MIJSONValueInterpolationMedium = @"kCGInterpolationMedium";
NSString *const MIJSONValueInterpolationHigh = @"kCGInterpolationHigh";

// Key and Values related to the UI Font Type.

NSString *const MIJSONKeyUIFontType = @"userinterfacefont";

NSString *const MIJSONValueUIFontUser = @"kCTFontUIFontUser";
NSString *const MIJSONValueUIFontFixedPitch = @"kCTFontUIFontUserFixedPitch";
NSString *const MIJSONValueUIFontSystem = @"kCTFontUIFontSystem";
NSString *const MIJSONValueUIFontEmphasizedSystem = @"kCTFontUIFontEmphasizedSystem";
NSString *const MIJSONValueUIFontSmallSystem = @"kCTFontUIFontSmallSystem";
NSString *const MIJSONValueUIFontSmallEmphasizedSytem =
                                            @"kCTFontUIFontSmallEmphasizedSystem";
NSString *const MIJSONValueUIFontMiniSystem = @"kCTFontUIFontMiniSystem";
NSString *const MIJSONValueUIFontMiniEmphasizedSystem =
                                            @"kCTFontUIFontMiniEmphasizedSystem";
NSString *const MIJSONValueUIFontViews = @"kCTFontUIFontViews";
NSString *const MIJSONValueUIFontApplication = @"kCTFontUIFontApplication";
NSString *const MIJSONValueUIFontLabel = @"kCTFontUIFontLabel";
NSString *const MIJSONValueUIFontMenuTitle = @"kCTFontUIFontMenuTitle";
NSString *const MIJSONValueUIFontMenuItem = @"kCTFontUIFontMenuItem";
NSString *const MIJSONValueUIFontWindowTitle = @"kCTFontUIFontWindowTitle";
NSString *const MIJSONValueUIFontPushButton = @"kCTFontUIFontWindowTitle";
NSString *const MIJSONValueUIFontSystemDetail = @"kCTFontUIFontSystemDetail";
NSString *const MIJSONValueUIFontEmphasizedSystemDetail =
                                        @"kCTFontUIFontEmphasizedSystemDetail";
NSString *const MIJSONValueUIFontToolbar = @"kCTFontUIFontToolbar";
NSString *const MIJSONValueUIFontSmallToolbar = @"kCTFontUIFontSmallToolbar";
NSString *const MIJSONValueUIFontMessage = @"kCTFontUIFontMessage";
NSString *const MIJSONValueUIFontToolTip = @"kCTFontUIFontToolTip";
NSString *const MIJSONValueUIFontControlContent = @"kCTFontUIFontControlContent";

// Key and Values related to text alignment for paragraph attributes.

NSString *const MIJSONKeyTextAlignment = @"textalignment";

NSString *const MIJSONValueTextAlignLeft = @"kCTTextAlignmentLeft";
NSString *const MIJSONValueTextAlignRight = @"kCTTextAlignmentRight";
NSString *const MIJSONValueTextAlignCenter = @"kCTTextAlignmentCenter";
NSString *const MIJSONValueTextAlignJustified = @"kCTTextAlignmentJustified";
NSString *const MIJSONValueTextAlignNatural = @"kCTTextAlignmentNatural";

#pragma mark - Commands and Object related options, properties keys and values.

// Accessing base objects.

NSString *const MIJSONKeySourceObject = @"sourceobject"; // dictionary
NSString *const MIJSONKeyReceiverObject = @"receiverobject"; // dictionary.

NSString *const MIJSONKeyObjectReference = @"objectreference"; // reference (int)
NSString *const MIJSONKeyObjectName = @"objectname"; // string
NSString *const MIJSONKeyObjectType = @"objecttype"; // string
NSString *const MIJSONKeyObjectIndex = @"objectindex"; // integer. Use rarely.

NSString *const MIJSONKeyImageIndex = @"imageindex"; // integer
NSString *const MIJSONKeySecondaryImageIndex = @"secondaryimageindex"; // integer
NSString *const MIJSONKeyImageOptions = @"imageoptions"; // dictonary

NSString *const MIKSONKeyGrabMetadata = @"grabmetadata"; // BOOL. YES/NO

// Property keys and property values for configuring how commands are run.

NSString *const MIJSONKeyCommands = @"commands"; // [ array of commands ]
NSString *const MIJSONKeyAsyncCompletionCommands = @"asynccompletioncommands";//dict
NSString *const MIJSONKeyStopOnFailure = @"stoponfailure"; // "YES", "NO"
NSString *const MIJSONKeyReturns = @"returns"; // A string, one of three values
NSString *const MIJSONKeyRunAsynchronously = @"runasynchronously"; // "YES", "NO"
NSString *const MIJSONKeySaveResultsTo = @"saveresultsto"; // path to a file.
NSString *const MIJSONKeySaveResultsType = @"saveresultstype";//"jsonfile", ...
NSString *const MIJSONKeyGetDataFrom = @"getdatafrom"; // path to a file.
NSString *const MIJSONKeyGetDataType = @"getdatatype"; // "jsonfile", ...
NSString *const MIJSONKeyInputData = @"inputdata"; // a json string or dictionary
NSString *const MIJSONKeyCleanupCommands = @"cleanupcommands"; // array of dicts.

NSString *const MIJSONValueYes = @"YES";
NSString *const MIJSONValueNo = @"NO";

// property values for property key MIJSONKeyReturns "returns".

NSString *const MIJSONValueReturnLastCommand = @"lastcommandresult";
NSString *const MIJSONValueReturnListOfResults = @"listofresults";
NSString *const MIJSONValueReturnNone = @"noresults";

// The command key followed by command values.

NSString *const MIJSONKeyCommand = @"command";

// The commands. Property values for the command property MIJSONKeyCommand.

NSString *const MIJSONValueGetPropertyCommand = @"getproperty";
NSString *const MIJSONValueGetPropertiesCommand = @"getproperties";
NSString *const MIJSONValueSetPropertyCommand = @"setproperty";
NSString *const MIJSONValueSetPropertiesCommand = @"setproperties";
NSString *const MIJSONValueCreateCommand = @"create";
NSString *const MIJSONValueCloseCommand = @"close";
NSString *const MIJSONValueCloseAllCommand = @"closeall";
NSString *const MIJSONValueAddImageCommand = @"addimage";
NSString *const MIJSONValueExportCommand = @"export";
NSString *const MIJSONValueDrawElementCommand = @"drawelement";
NSString *const MIJSONValueSnapshotCommand = @"snapshot";
NSString *const MIJSONValueFinalizePageCommand = @"finalizepage";
NSString *const MIJSONValueGetPixelDataCommand = @"getpixeldata";
NSString *const MIJSONValueCalculateGraphicSizeOfTextCommand =
                                                    @"calculategraphicsizeoftext";
NSString *const MIJSONValueRenderFilterChainCommand = @"renderfilterchain";
NSString *const MIJSONValueAssignImageToCollectionCommand =
                                                    @"assignimagetocollection";
NSString *const MIJSONValueRemoveImageFromCollectionCommand =
                                                    @"removeimagefromcollection";
NSString *const MIJSONValueProcessFramesCommand = @"processframes";
NSString *const MIJSONValueCreateTrackCommand = @"createtrack";
NSString *const MIJSONValueAddMovieInstruction = @"addmovieinstruction";
NSString *const MIJSONValueAddAudioMixInstruction = @"addaudiomixinstruction";
NSString *const MIJSONValueInsertEmptyTrackSegment = @"insertemptytracksegment";
NSString *const MIJSONValueInsertTrackSegment = @"inserttracksegment";
NSString *const MIJSONValueAddInputToMovieFrameWriterCommand =
                                                    @"addinputtowriter";
NSString *const MIJSONValueFinishWritingFramesCommand = @"finishwritingframes";
NSString *const MIJSONValueCancelWritingFramesCommand = @"cancelwritingframes";
NSString *const MIJSONValueAddImageSampleToWriterCommand =
                                                    @"addimagesampletowriter";

// Property related keys

NSString *const MIJSONPropertyKey = @"propertykey";
NSString *const MIJSONPropertyValue = @"propertyvalue";

//
// The properties.
//

// MovingImages property

NSString *const MIJSONPropertyVersion = @"version";

// Class type properties for all classes

NSString *const MIJSONPropertyNumberOfObjects = @"numberofobjects";

// Options

NSString *const MIJSONPropertyDictionary = @"dictionary"; // starts a key path.

// Values used most often for saveresultstype:
NSString *const MIJSONPropertyJSONString = @"jsonstring";
NSString *const MIJSONPropertyJSONFilePath = @"jsonfile";
NSString *const MIJSONPropertyPropertyFilePath = @"propertyfile";
NSString *const MIJSONPropertyDictionaryObject = @"dictionaryobject";

// The file property, used when creating importer and pdf context objects etc..
NSString *const MIJSONPropertyFile = @"file";

NSString *const MIJSONPropertyPathSubstitution = @"pathsubstitution";

// Each MIContext has a image collection. This is a key for an image identifier.
NSString *const MIJSONPropertyImageIdentifier = @"imageidentifier";

// Properties of imageimporter and image exporter objects

NSString *const MIJSONPropertyNumberOfImages = @"numberofimages";
NSString *const MIJSONPropertyFileType = @"utifiletype";

// imageexporter class property specific keys

NSString *const MIJSONPropertyAvailableExportTypes = @"imageexporttypes";

// imageexporter object property specific keys

NSString *const MIJSONPropertyCanExport = @"canexport";
NSString *const MIJSONPropertyExportCompressionQuality =
                                                @"exportcompressionquality";

// imageimporter property specific keys

NSString *const MIJSONPropertyImageSourceStatus = @"imagesourcestatus";
NSString *const MIJSONPropertyImageImportTypes = @"imageimporttypes";
NSString *const MIJSONPropertyAllowFloatingPointImages =
                                                @"allowfloatingpointimages";

// movieimporter and editor property keys
NSString *const MIJSONPropertyMovieImportTypes = @"movieimporttypes";
NSString *const MIJSONPropertyMovieImportMIMETypes = @"movieimportmimetypes";
NSString *const MIJSONPropertyMovieExportTypes = @"movieexporttypes";
NSString *const MIJSONPropertyMovieTrackID = @"trackid";
NSString *const MIJSONPropertyMovieTrackIndex = @"trackindex";
NSString *const MIJSONPropertyMovieMediaType = @"mediatype";
NSString *const MIJSONPropertyMovieMediaTypes = @"mediatypes";
NSString *const MIJSONPropertyMovieMediaCharacteristic = @"mediacharacteristic";
NSString *const MIJSONPropertyMovieMediaCharacteristics = @"mediacharacteristics";
NSString *const MIJSONPropertyMovieNumberOfTracks = @"numberoftracks";
NSString *const MIJSONPropertyMovieCommonMetadata = @"commonmetadata";
NSString *const MIJSONPropertyMovieMetadata = @"metadata";
NSString *const MIJSONPropertyMovieMetadataFormats = @"metadataformats";
NSString *const MIJSONPropertyMovieTrack = @"track";
NSString *const MIJSONPropertyMovieSourceTrack = @"sourcetrack";
NSString *const MIJSONPropertyMovieTracks = @"tracks";
NSString *const MIJSONPropertyMovieDuration = @"duration";
NSString *const MIJSONPropertyMovieCurrentTime = @"currenttime";
NSString *const MIJSONPropertyMovieTimeRangeStart = @"start";
NSString *const MIJSONPropertyMovieTimeRangeDuration = @"duration";
NSString *const MIJSONPropertyMovieTrackEnabled = @"trackenabled";
NSString *const MIJSONPropertyMovieTimeRange = @"timerange";
NSString *const MIJSONPropertyMovieInsertionTime = @"insertiontime";
NSString *const MIJSONPropertyMovieLanguageCode = @"languagecode";
NSString *const MIJSONPropertyMovieExtendedLanguageTag = @"languagetag";
NSString *const MIJSONPropertyMovieNaturalSize = @"naturalsize";
NSString *const MIJSONPropertyMovieTrackNaturalSize = @"naturalsize";
NSString *const MIJSONKeyMovieTrackPreferredVolume = @"preferredvolume";
NSString *const MIJSONPropertyMovieTrackNominalFrameRate = @"framerate";
NSString *const MIJSONPropertyMovieTrackMinFrameDuration = @"minframeduration";
NSString *const MIJSONPropertyMovieFrameDuration = @"frameduration";

// NSString *const MIJSONPropertyMovieEditorInstruction = @"movieeditorinstruction";
NSString *const MIJSONPropertyMovieEditorLayerInstructions =  @"layerinstructions";

NSString *const MIJSONKeyMovieEditorLayerInstructionType = @"layerinstructiontype";

NSString *const MIJSONValueMovieEditorPassthruInstruction = @"passthruinstruction";
NSString *const MIJSONValueMovieEditorTransformRampInstruction = @"transformramp";
NSString *const MIJSONValueMovieEditorOpacityRampInstruction = @"opacityramp";
NSString *const MIJSONValueMovieEditorCropRampInstruction = @"cropramp";

NSString *const MIJSONValueMovieEditorTransformInstruction =
                                                        @"transforminstruction";
NSString *const MIJSONValueMovieEditorOpacityInstruction = @"opacityinstruction";
NSString *const MIJSONValueMovieEditorCropInstruction = @"cropinstruction";

NSString *const MIJSONKeyMovieEditorAudioInstruction = @"audioinstruction";

NSString *const MIJSONValueMovieEditorVolumeInstruction = @"volumeinstruction";
NSString *const MIJSONValueMovieEditorVolumeRampInstruction = @"volumerampinstruction";

NSString *const MIJSONPropertyMovieEditorStartRampValue = @"startrampvalue";
NSString *const MIJSONPropertyMovieEditorEndRampValue = @"endrampvalue";
NSString *const MIJSONPropertyMovieEditorInstructionValue = @"instructionvalue";

NSString *const MIJSONPropertyMovieTrackRequiresFrameReordering =
                                                    @"requiresframereordering";
NSString *const MIJSONPropertyMovieTrackSegmentMappings = @"tracksegmentmappings";
NSString *const MIJSONPropertyMovieSourceTimeRange = @"sourcetimerange";
NSString *const MIJSONPropertyMovieTargetTimeRange = @"targettimerange";
NSString *const MIJSONPropertyMovieFrameTime = @"frametime";
NSString *const MIJSONPropertyMovieLastAccessedFrameDurationKey =
                                            @"lastaccessedframedurationkey";
NSString *const MIJSONValueMovieNextSample = @"movienextsample";
NSString *const MIJSONPropertyMovieTime = @"time";
NSString *const MIJSONPropertyMovieTimeInSeconds = @"timeinseconds";
NSString *const MIJSONPropertyMovieProcessInstructions = @"processinstructions";
NSString *const MIJSONPropertyMoviePreProcess = @"preprocess";
NSString *const MIJSONPropertyMoviePostProcess = @"postprocess";
NSString *const MIJSONPropertyMovieLocalContext = @"localcontext";

NSString *const MIJSONValueMovieMediaTypeVideo = @"vide";
NSString *const MIJSONValueMovieMediaTypeAudio = @"soun";

NSString *const MIJSONPropertyMovieVideoWriterPreset = @"preset";
NSString *const MIJSONPropertyMovieVideoWriterPresets = @"presets";
NSString *const MIJSONPropertyMovieVideoWriterSettings = @"videosettings";
NSString *const MIJSONPropertyMovieVideoWriterCanWriteFrames = @"canwriteframes";
NSString *const MIJSONPropertyMovieVideoWriterStatus = @"videowriterstatus";

NSString *const MIJSONValueMovieVideoWriterPresetH264_HD = @"h264preset_hd";
NSString *const MIJSONValueMovieVideoWriterPresetH264_SD = @"h264preset_sd";
NSString *const MIJSONValueMovieVideoWriterPresetJPEG = @"jpegpreset";
NSString *const MIJSONValueMovieVideoWriterPresetProRes4444 = @"prores4444preset";
NSString *const MIJSONValueMovieVideoWriterPresetProRes422 = @"prores422preset";

NSString *const MIJSONPropertyMovieExportCompatiblePresets = @"compatiblepresets";
NSString *const MIJSONPropertyMovieExportPreset = @"preset";

// bitmapcontext, nsgraphicscontext, and core image command option.

NSString *const MIJSONPropertyCreateImage = @"createimage";

// bitmapcontext class type property specific keys

NSString *const MIJSONPropertyPresets = @"presets";
NSString *const MIJSONPropertyBlendModes = @"blendmodes";
NSString *const MIJSONPropertyUserInterfaceFonts = @"userinterfacefonts";

// bitmapcontext object property specific keys

NSString *const MIJSONPropertyPreset = @"preset"; // MIJSONPropertyMoviePreset
NSString *const MIJSONPropertyColorProfile = @"colorprofile";
NSString *const MIJSONPropertyBitsPerComponent = @"bitspercomponent";
NSString *const MIJSONPropertyBitsPerPixel = @"bitsperpixel";
NSString *const MIJSONPropertyBytesPerRow = @"bytesperrow";
NSString *const MIJSONPropertyColorSpaceName = @"colorspacename";
NSString *const MIJSONPropertyAlphaAndBitmapInfo = @"alphaandbitmapinfo";

NSString *const MIJSONValueDeviceRGB = @"devicergb";

// bitmapcontext option keys:

NSString *const MIJSONPropertyDrawInstructions = @"drawinstructions";
NSString *const MIJSONPropertySnapshotAction = @"snapshotaction";

// bitmapcontext option values:

NSString *const MIJSONValueTakeSnapshot = @"takesnapshot";
NSString *const MIJSONValueDrawSnapshot = @"drawsnapshot";
NSString *const MIJSONValueClearSnapshot = @"clearsnapshot";

// MINSGraphicContext class and object property specific keys.

NSString *const MIJSONPropertyWindowRectangle = @"windowrectangle";
NSString *const MIJSONPropertyBorderlessWindow = @"borderlesswindow";

// Core Image class and object property specific keys.

NSString *const MIJSONPropertyImageFilters = @"imagefilters";
NSString *const MIJSONPropertyFilterCategory = @"filtercategory";
NSString *const MIJSONPropertyImageFilterAttributes = @"filterattributes";
NSString *const MIJSONPropertyImageFilterChain = @"imagefilterchaindict"; // dict
NSString *const MIJSONPropertyRenderInstructions = @"renderinstructions"; // dict
NSString *const MIJSONPropertyImageFilterName = @"filtername"; // string - filter
NSString *const MIJSONPropertySoftwareRender = @"softwarerender"; // YES/NO
NSString *const MIJSONPropertyUseSRGBColorSpace = @"use_srgbcolorspace"; //YES/NO
