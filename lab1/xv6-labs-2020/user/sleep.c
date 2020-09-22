#include "kernel/types.h"
#include "user/user.h"
int main(int argc, char* argv[]) {
	if(argc != 2) {
		fprintf(2, "Usage: sleep [ticks]\n");
		exit(1);
	}
	if(sleep(atoi(argv[1]) < 0)) {
		fprintf(2, "Failed to sleep %s ticks.\n", argv[1]);
		exit(1);
	}
	exit(0);
}
