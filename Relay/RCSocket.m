//
//  RCSocket.m
//  Relay
//
//  Created by Max Shavrick on 3/11/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCSocket.h"

@implementation RCSocket
@synthesize delegate;

- (void)initSockaddtr:(struct sockaddr_in *)name port:(unsigned short int)port hostName:(const char *)hostName {
	struct hostent *hostinfo;
	
	name->sin_family = AF_INET;
	name->sin_port = htons (port);
	hostinfo = gethostbyname ([[delegate server] UTF8String]);
	if (hostinfo == NULL) {
		fprintf (stderr, "Unknown host %s.\n", hostName);
		exit (EXIT_FAILURE);
    }
	name->sin_addr = *(struct in_addr *) hostinfo->h_addr;
}

- (BOOL)connect {
	register int s;
	register int bytes;
	struct sockaddr_in sa;
	char buffer[BUFSIZ+1];
	
	if ((s = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
		perror("socket");
		return 1;
	}
	
	bzero(&sa, sizeof sa);
	
	sa.sin_family = AF_INET;
	sa.sin_port = htons(6667);
	sa.sin_addr.s_addr = htonl((((((74 << 8) | 208) << 8) | 44) << 8) | 105);
	if (connect(s, (struct sockaddr *)&sa, sizeof sa) < 0) {
		perror("connect");
		close(s);
		return 2;
	}
	char setup[] = "USER max max max max\r\nNICK max__\r\nJOIN #bacon\r\n";
	write(1, setup, sizeof(setup));
	while ((bytes = read(s, buffer, BUFSIZ)) > 0)
		write(1, buffer, bytes);
	
	return 0;
	
	
	/*
	int sock, status, i;
	fd_set active_fd_set, read_fd_set;
	struct sockaddr_in clientName;
	size_t size;
	sock = make_socket((unsigned short int)[delegate port]);
	if (listen(sock, 1) < 0) {
		NSLog(@"SPOLODEE");
		return NO;
	}
	FD_ZERO(&active_fd_set);
	FD_SET(sock, &active_fd_set);
	while (1) {
		read_fd_set = active_fd_set;
		if (select(FD_SETSIZE, &read_fd_set, NULL, NULL, NULL) < 0) {
			return NO;
		}
	}
	for (i = 0; i <FD_SETSIZE; i++) {
		if (FD_ISSET(i, &read_fd_set)) {
			if (i == sock) {
				size = sizeof(clientName);
				if (accept(sock, (struct sockaddr *)&clientName, &size) < 0) {
					return NO;
				}
				fprintf (stderr, "Server: connect from host %s, port %hd.\n",
						 inet_ntoa (clientName.sin_addr),
						 ntohs (clientName.sin_port));
				FD_SET(status, &active_fd_set);
			}
			else {
				if (readFromClient(i) < 0) {
					close(i);
					FD_CLR(i, &active_fd_set);
				}
			}
			
		}
	}
	
	int sock;
	struct sockaddr_in serverName;
	sock = socket(PF_INET, SOCK_STREAM, 0);
	if (sock < 0) {
		NSLog(@"FUUUUUUU");
	}
	[self initSockaddtr:&serverName port:6667 hostName:"irc.saurik.com"];
	if (0 > connect(sock, (struct sockaddr *)&serverName, sizeof(serverName))) {
		NSLog(@"FUUUUUUUUUUUUU");
	}
	int bytes;
	bytes = write(sock, "USER max max max max\r\nNICK max max max max\r\n", strlen("USER max max max max\r\nNICK max max max max\r\n")+1);
	NSLog(@"HAOMAny %d", bytes);*/
	return YES;
}
int make_socket (unsigned short int port);
int make_socket (unsigned short int port) {
	int sock;
	struct sockaddr_in name;
	
	/* Create the socket.  */
	sock = socket (PF_INET, SOCK_STREAM, 0);
	if (sock < 0)
    {
		perror ("socket");
		exit (EXIT_FAILURE);
    }
	
	/* Give the socket a name.  */
	name.sin_family = AF_INET;
	name.sin_port = htons (port);
	name.sin_addr.s_addr = htonl (INADDR_ANY);
	if (bind (sock, (struct sockaddr *) &name, sizeof (name)) < 0)
    {
		perror ("bind");
		exit (EXIT_FAILURE);
    }
	
	return sock;
}
int readFromClient(int files);
int readFromClient(int files) {
	char buffer[512];
	int bytes;
	bytes = read(files, buffer, 512);
	if (bytes < 0) NSLog(@"shhiiittt");
	NSLog(@"Yay. %s", buffer);
	return 0;
}


@end
