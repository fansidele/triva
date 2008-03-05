/*

#include <Foundation/Foundation.h>
#include "general/ProtoComponent.h"
#include "core/ProtoController.h"
#include <argtable2.h>

int main(int argc, char *argv[])
{
	struct arg_file *syncfile = arg_file0("s", "sync", "<FILE>", "timesync file");
	struct arg_lit *help = arg_lit0(NULL,"help","print this help and exit");
	struct arg_lit *version = arg_lit0(NULL,"version","print version information and exit");
	struct arg_file *traces = arg_filen(NULL, NULL, "FILE", 1, 5000, NULL);
	struct arg_end *end = arg_end(20);
	void* argtable[] = {syncfile,help,version,traces,end};
	const char *progname = "triva";
	int nerrors;
	
	if (arg_nullcheck(argtable) != 0){
		printf("%s: insufficient memory\n",progname);
		exit(1);
	}

	nerrors = arg_parse(argc,argv,argtable);
	
	if (help->count > 0) {
		printf("Usage: %s", progname);
		arg_print_syntax(stdout,argtable,"\n");
		arg_print_glossary(stdout,argtable,"  %-25s %s\n");
		exit(0);
	}
	if (version->count > 0) {
		printf("TRIVA - ThRee dimension Interactive Visual Analysis.\n");
		printf("February 2008, Lucas Schnorr\n");
		exit(0);
	}
	if (nerrors > 0){
		arg_print_errors(stdout,end,progname);
		printf("Try '%s --help' for more information.\n",progname);
		exit(1);
	}
	if (argc==1) {
		printf("Try '%s --help' for more information.\n",progname);
		exit(0);
	}

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *tsStr;
	if (syncfile->count != 0){
		tsStr= [NSString stringWithFormat: @"%s",syncfile->filename[0]];
	}else{
		tsStr= @"NONE";
	}
	int i;
	NSMutableArray *tfAr = [NSMutableArray array];
	for (i = 0; i < traces->count; i++){
		[tfAr addObject: [NSString stringWithFormat: @"%s",traces->filename[i]]];
	}

	ProtoController *controller = [[ProtoController alloc] initWithArgc: (int) argc andArgv: (char **) argv];
	[controller setSyncfile: tsStr];
	[controller setTracefile: tfAr];
	if (controller != nil){
		[controller start];
		[controller release];
	}
	[pool release];
	return 0;
}
*/
