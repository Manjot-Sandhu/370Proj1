/*
 * Name: Manjot Sandhu
 * NSHE: 2002318029
 * Class Section: 1001
 * Assignment: Project 2
 * Description: Short program that calculates how long a child process runs for and executes user's command.
 */

#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"
int main(int argc, char *argv[]){
	int startTime = uptime();
	int rc = fork();
	if (rc < 0){
		fprintf(2, "Fork failed\n");
		exit(1);
	} else if (rc == 0){
		exec(argv[1], &argv[1]);

		fprintf(2, "Exec failed for command:");
		for(int i = 1; argv[i] != 0; i++){
			fprintf(2, " %s", argv[i]);
		}
		fprintf(2, "\n");
	}else{
		int status;
		wait(&status);

		int endTime = uptime();
		fprintf(2, "\nReal-time: %d miliseconds\n", (endTime - startTime) * 100);
	}
	return 0;
}

