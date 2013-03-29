#import "SdimMacController.h"
#import "ConversionEngine.h"
#import "SdimMacApplicationDelegate.h"
#include "Python/Python.h"
#include <stdlib.h>

SdimMacController* theController;
PyObject* myProcessEvent;
id theSender;


/* startx code-generator 
   expand <<EOF
   $(perl -ne 'if (m/sdimUiMethods.*=/ .. m/null, null, 0/i) {
       m/\{"(.*?)",/ or next;
       printf "static PyObject* %s(PyObject* self, PyObject* pArgs) {\n", $1;
       printf "%s\n", '\''NSLog(@"%s:%d:%s: ", __FILE__, __LINE__, __FUNCTION__);'\'';
       printf "%s\n", "Py_INCREF(Py_None);";
       printf "%s\n", "return Py_None;";
       printf "%s\n", "}";
   }' ~/src/github/sdim-mac/SdimMacController.m)
EOF
   endx code-generator */
// start generated code
static PyObject* update_preedit_text(PyObject* self, PyObject* pArgs) {
    char *preedit = NULL;
    if (!PyArg_ParseTuple(pArgs, "s", &preedit)) {
	NSLog(@"%s:%d:%s: parse failed", __FILE__, __LINE__, __FUNCTION__);
	return NULL;
    }

    NSString* preEdit = [NSString stringWithUTF8String:preedit];

    [theController setPreEditStr:preEdit];
    [theSender setMarkedText:preEdit selectionRange:NSMakeRange(0, [preEdit length]) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    Py_INCREF(Py_None);
    return Py_None;
}
static PyObject* update_auxiliary_text(PyObject* self, PyObject* pArgs) {
    Py_INCREF(Py_None);
    return Py_None;
}
static PyObject* hide_auxiliary_text(PyObject* self, PyObject* pArgs) {
    Py_INCREF(Py_None);
    return Py_None;
}
static PyObject* hide_lookup_table(PyObject* self, PyObject* pArgs) {
    Py_INCREF(Py_None);
    return Py_None;
}

NSMutableArray* theCandidates;
static PyObject* clear_lookup_table(PyObject* self, PyObject* pArgs) {
    [theCandidates removeAllObjects];
    Py_INCREF(Py_None);
    return Py_None;
}
static PyObject* append_candidate(PyObject* self, PyObject* pArgs) {
    char * cand = NULL;
    if (!PyArg_ParseTuple(pArgs, "s", &cand)) {
	NSLog(@"%s:%d:%s: parse failed", __FILE__, __LINE__, __FUNCTION__);
	return NULL;
    }
    
    NSString* candStr = [NSString stringWithUTF8String:cand];
    [theCandidates addObject:candStr];

    Py_INCREF(Py_None);
    return Py_None;
}
static PyObject* set_cursor_pos_in_current_page(PyObject* self, PyObject* pArgs) {
    Py_INCREF(Py_None);
    return Py_None;
}
static PyObject* update_lookup_table(PyObject* self, PyObject* pArgs) {
    [theController showCandidates];
    Py_INCREF(Py_None);
    return Py_None;
}
static PyObject* commit_text(PyObject* self, PyObject* pArgs) {

    char *commit = NULL;
    if (!PyArg_ParseTuple(pArgs, "s", &commit)) {
	NSLog(@"%s:%d:%s: parse failed", __FILE__, __LINE__, __FUNCTION__);
	return NULL;
    }

    [theController commitStr:[NSString stringWithUTF8String:commit]];
	
    Py_INCREF(Py_None);
    return Py_None;
}

// end generated code

static PyMethodDef sdimUiMethods[] = {
	{"update_preedit_text", update_preedit_text, METH_VARARGS, "update preedit text"},
	{"update_auxiliary_text", update_auxiliary_text, METH_VARARGS, "update auxiliary text"},
	{"hide_auxiliary_text", hide_auxiliary_text, METH_VARARGS, "hide auxiliary text"},
	{"hide_lookup_table", hide_lookup_table, METH_VARARGS, "hide lookup table"},
	{"clear_lookup_table", clear_lookup_table, METH_VARARGS, "clear lookup table"},
	{"append_candidate", append_candidate, METH_VARARGS, "append candidate"},
	{"set_cursor_pos_in_current_page", set_cursor_pos_in_current_page, METH_VARARGS, "set cursor pos in current page"},
	{"update_lookup_table", update_lookup_table, METH_VARARGS, "update lookup table"},
	{"commit_text", commit_text, METH_VARARGS, "commit text"},
	{NULL, NULL, 0, NULL}
};

void pyProcessEvent(int keyCode, const char* chars, int mask) {
    PyObject* args = PyTuple_Pack(3, PyInt_FromLong(keyCode), PyString_FromString(chars), PyInt_FromLong(mask));
    PyObject_CallObject(myProcessEvent, args);
}

@implementation SdimMacController

-(BOOL)handleEvent:(NSEvent*)event client:(id)sender
{

    theSender = sender;
    unsigned int mask = [event modifierFlags];
    NSString* chars = [event characters];
    int keyCode = [event keyCode];

    if (! isgraph([chars UTF8String][0])) {
	if (! _preedit || [_preedit length] == 0) {
	    return NO;
	}
    }
    pyProcessEvent(keyCode, [chars UTF8String], mask);
    //NSLog(@"%@", event);
    return YES;
}

-(void)commitStr:(NSString*)str {
    [theSender insertText:str replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

-(NSMutableString*)composedBuffer;
{

	if ( _composedBuffer == nil ) {
		_composedBuffer = [[NSMutableString alloc] init];
	}
	return _composedBuffer;
}

-(void)setComposedBuffer:(NSString*)string
{

	NSMutableString*		buffer = [self composedBuffer];
	[buffer setString:string];
}

- (void)showCandidates {
    extern IMKCandidates*		candidates;
    [candidates setPanelType:kIMKSingleRowSteppingCandidatePanel];
    [candidates updateCandidates];
    [candidates show:kIMKLocateCandidatesBelowHint];
}

-(void) initPython {

    theCandidates = [NSMutableArray array];
    theController = self;

    Py_SetProgramName("Sdim Mac");

    // Initialize the Python interpreter.
    Py_Initialize();

    Py_InitModule("sdim_ui", sdimUiMethods);
	
    PyRun_SimpleString(
		       
		       /* start code-generator 
			  expand <<EOF | here-doc-to-cstr | append-line-number //
			  import sdim_ui
			  import sys, os
			  sys.path.append(os.path.expanduser("~/src/github/sdim-mac/"))
			  import sdim_mac
			  sdim_mac.engine = sdim_mac.tabengine()
			  sdim_mac.sdim_ui = sdim_ui
EOF
			  end code-generator */
		       // start generated code
		       "import sdim_ui\n" // 1
		       "import sys, os\n" // 2
		       "sys.path.append(os.path.expanduser(\"~/src/github/sdim-mac/\"))\n" // 3
		       "import sdim_mac\n" // 4
		       "sdim_mac.engine = sdim_mac.tabengine()\n" // 5
		       "sdim_mac.sdim_ui = sdim_ui\n" // 6

		       // end generated code
		       );

    PyObject* myModuleString = PyString_FromString((char*)"sdim_mac");
    PyObject* myModule = PyImport_Import(myModuleString);

    PyObject* myEngine = PyObject_GetAttrString(myModule,(char*)"engine");
    myProcessEvent = PyObject_GetAttrString(myEngine, "process_key_event");

    
}

-(void)setValue:(id)value forTag:(long)tag client:(id)sender
{

    if (! theController) {
	[self initPython];
    }

    //PyRun_SimpleString("sdim_ui.processEventResults('6')\n");

	NSString*		newModeString = (NSString*)value;
	NSNumberFormatterStyle	currentMode = [[[NSApp delegate] conversionEngine] conversionMode];
	NSNumberFormatterStyle newMode;
	
	if ( [newModeString isEqual:kDecimalMode] ) {
		newMode = NSNumberFormatterDecimalStyle;
	}
	else if ( [newModeString isEqual:kCurrencyMode] ) {
		newMode = NSNumberFormatterCurrencyStyle;
	}
	else if ( [newModeString isEqual:kPercentMode] ) {
		newMode = NSNumberFormatterPercentStyle;
	}
	else if ( [newModeString isEqual:kScientificMode] ) {
		newMode = NSNumberFormatterScientificStyle;
	}
	else if ( [newModeString isEqual:kSpelloutMode] ) {
		newMode = NSNumberFormatterSpellOutStyle;
	}
	
	if ( currentMode != newMode ) {
		[[[NSApp delegate] conversionEngine] setConversionMode:newMode];
	}
}

- (NSArray*)candidates:(id)sender
{
    return theCandidates;
}

- (void)candidateSelectionChanged:(NSAttributedString*)candidateString
{

	[theSender setMarkedText:[candidateString string] selectionRange:NSMakeRange(_insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
	_insertionIndex = [candidateString length];
}

- (void)candidateSelected:(NSAttributedString*)candidateString
{

	[self setComposedBuffer:[candidateString string]];
	[self commitComposition:theSender];
}



-(void)setPreEditStr:(NSString*)string {
    NSLog(@"%s:%d:%s: preedit set to '%@'\n", __FILE__, __LINE__, __FUNCTION__, string);
    _preedit = string;
}

-(NSString*)preEditStr {
    return _preedit;
}
 
@end
