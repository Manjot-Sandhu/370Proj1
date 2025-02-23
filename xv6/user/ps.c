/*
 * Name: Manjot Sandhu
 * NSHE: 2002318029
 * Class Section: 1001
 * Assignment: Project 3
 * Description: Made our own system call to show current processes running on the OS.
 */

#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"
int main(int argc, char *argv[]){
	showProcs();
	exit(0);
}
