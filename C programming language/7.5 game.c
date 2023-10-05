/*
This program was coded on C programming language.
This is a game called 7 ½ (Similar to BlackJack but using spanish cards).

The objective of this program was to use fork() system call to generate player processes, and File Descriptors (fd[]/(read()/write() calls) to 
communicate the dealer process with the player process.
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

#define NUM_CHILD 3

struct player {
    int bet,winnings,handsWon,timesStood,timesSurrendered;
    bool stood;
    bool surrendered;
    float pointsTotal;
    
};

struct player playeres[NUM_CHILD];


int main(void)
{
    pid_t pidC;
    int fd[2];
    int mainLoop = 0;
    float aux;
    int playeresSurrendered;
    int playersStood;
    int foldedPlayers;
    
    mainWhileLoop:
    while(mainLoop == 0){ //Infinite loop so the game doesn't stop.
            
            
        
        
        wait(NULL);
        pidC = fork();
        
        if (pidC == 0){ //Parent process
            
            if(foldedPlayers == NUM_CHILD){
            printf("\nThe dealer wins\n");
            for(int i=0 ; i<=NUM_CHILD ; i++ ){
                playeres[i].pointsTotal = 0;    //We reset the points of all players.
                playeres[i].surrendered = 0;
                playeres[i].stood = 0;
                playeres[i].bet = 0;
                close(fd[0]);
                write(fd[1], &playeres[i].pointsTotal, sizeof(playeres[i].pointsTotal));
                close(fd[1]);
                write(fd[1], &playeres[i].surrendered, sizeof(playeres[i].surrendered));
                close(fd[1]);
                write(fd[1], &playeres[i].stood, sizeof(playeres[i].stood));
                close(fd[1]);
                write(fd[1], &playeres[i].bet, sizeof(playeres[i].bet));
                close(fd[1]);
               }
            foldedPlayers = 0;
            playersStood = 0;
            playeresSurrendered = 0;
            write(fd[1], &foldedPlayers, sizeof(foldedPlayers));
            close(fd[1]);
            write(fd[1], &playersStood, sizeof(playersStood));
            close(fd[1]);
            write(fd[1], &playeresSurrendered, sizeof(playeresSurrendered));
            close(fd[1]);
            close(fd[0]);
            goto mainWhileLoop;   
        }
            
            forLoop:
            for(int i=0 ; i<=NUM_CHILD ; i++ ){
                
                sleep (1);
            
                srand(time(0));
                int card;
                int response;
                float points;
                int menuLoop = 0;
                
                if (i == NUM_CHILD && playeres[i].pointsTotal < 7.5){    //The last number represents the dealer.
                    card = rand() %12 +1;
                    float points;
                    
                        if (card > 7){
                            points = 0.5;
                        }
                        else{
                           points = card;
                        }
                        playeres[i].pointsTotal = playeres[i].pointsTotal + points;
                        //printf("\nDealer - Score: %f\n\n", playeres[i].pointsTotal);
                        goto mainWhileLoop;
                    }
                
                
                if(playeres[i].surrendered == 1){
                    playeres[i].pointsTotal == 0;   //If the player surrendered, we set his points to 0 and go back to mainLoop.
                    goto forLoop;
                }
                else if(playeres[i].stood == 1){
                    goto forLoop;  //If the player stood, we leave the points as they are and go back to mainLoop.
                }
                
                while (menuLoop == 0){
                    printf("player %d, choose an option: \n", i);
                    printf("1.Get a card\n2.Stood\n3.Surrender\n\nOption: ");
                    scanf("%d", &response);
                    if (response > 0 && response < 4){
                        menuLoop++;
                        }
                    else{
                        printf ("\nChoose a valid option.\n\n");
                    }
                }
                 
                switch(response){
                        case 1:
                        
                        if (playeres[i].bet == 0){
                            
                        
                            printf ("Enter your bet: ");
                            scanf("%d", &playeres[i].bet);
                            card = rand() %12 +1;
                        
                            if (card > 7){
                                points = 0.5;
                            }
                            else{
                               points = card;
                            }
                            printf("\n");
                        }    
                    
                    
                        playeres[i].pointsTotal = playeres[i].pointsTotal + points;
                    
                        close(fd[0]);
                        write(fd[1], &playeres[i].pointsTotal , sizeof(playeres[i].pointsTotal));
                        close(fd[1]);
                        printf("player % d - Puntaje: %f \n\n", i , playeres[i].pointsTotal);
                        sleep(1);
                        system("clear");
                        
                        
                        
                        
                        break;
                        
                    case 2:
                        playeres[i].stood = 1;
                        playeres[i].timesStood++;
                        playersStood++;
                        foldedPlayers++;
                        close(fd[0]);
                        write(fd[1], &playeres[i].stood , sizeof(playeres[i].stood));
                        close(fd[1]);
                        write(fd[1], &playersStood, sizeof(playersStood));
                        close(fd[1]);
                        write(fd[1], &foldedPlayers, sizeof(foldedPlayers));
                        close(fd[1]);
                        system("clear");
                        break;
                    case 3:
                        playeres[i].surrendered = 1;
                        playeres[i].timesSurrendered++;
                        playeresSurrendered++;
                        foldedPlayers++;
                        close(fd[0]);
                        write(fd[1], &playeres[i].surrendered , sizeof(playeres[i].surrendered));
                        close(fd[1]);
                        write(fd[1], &playeresSurrendered, sizeof(playeresSurrendered));
                        close(fd[1]);
                        write(fd[1], &foldedPlayers, sizeof(foldedPlayers));
                        close(fd[1]);
                        system("clear");
                        break;
                    }
                
            }
            exit(0);
                
        }
        
        else if (pidC > 0){ //Parent process
            close(fd[1]);
            read(fd[0], &aux , sizeof(aux));
            
            for (int i=0 ; i<NUM_CHILD ; i++){
                printf("player %d | Hands won: %d | Times stood: %d | Times surrendered: %d\n", i, playeres[i].handsWon, playeres[i].timesStood, playeres[i].timesSurrendered);
            }
            printf("\n");
            
            for (int i=0 ; i<=NUM_CHILD ; i++){
                if(i == NUM_CHILD){
                    printf("Dealer - Score: %f \n\n", playeres[i].pointsTotal);
                }
                else{
                printf("player % d - Score: %f \n\n", i , playeres[i].pointsTotal);
                }
            }
            
            if(playeres[NUM_CHILD].pointsTotal == 7.5){
                printf("\nThe Dealer wins\n");
            }
            else{
                int winners = 0;
               for (int i=0 ; i<=NUM_CHILD ; i++){
                    
                    if(playeres[i].pointsTotal == 7.5){
                        printf("player %d: Winner of this hand\n",i);
                        printf("\nWinnings: %d\n", playeres[i].bet*2);
                        winners++;
                        playeres[i].handsWon++;
                    }
                }
            if (winners == 0 && playeres[NUM_CHILD].pointsTotal > 7.5){
                for (int i=0 ; i<=NUM_CHILD ; i++){
                    if(playeres[i].pointsTotal < 7.5){
                        printf("player %d: Winner of this hand\n",i);
                        printf("\nWinnings %d\n", playeres[i].bet*2);
                        playeres[i].handsWon++;
                    }
                }
            }
            
            }       
            
            if (playeres[NUM_CHILD].pointsTotal >= 7.5){
                for(int i=0 ; i<=NUM_CHILD ; i++ ){
                playeres[i].pointsTotal = 0;    //We reset the points of every player.
                playeres[i].surrendered = 0;
                playeres[i].stood = 0;
                playeres[i].bet = 0;
                close(fd[0]);
                write(fd[1], &playeres[i].pointsTotal, sizeof(playeres[i].pointsTotal));
                close(fd[1]);
                write(fd[1], &playeres[i].surrendered, sizeof(playeres[i].surrendered));
                close(fd[1]);
                write(fd[1], &playeres[i].stood, sizeof(playeres[i].stood));
                close(fd[1]);
                write(fd[1], &playeres[i].bet, sizeof(playeres[i].bet));
                close(fd[1]);
               }
            foldedPlayers = 0;
            playersStood = 0;
            playeresSurrendered = 0;
            write(fd[1], &foldedPlayers, sizeof(foldedPlayers));
            close(fd[1]);
            write(fd[1], &playersStood, sizeof(playersStood));
            close(fd[1]);
            write(fd[1], &playeresSurrendered, sizeof(playeresSurrendered));
            close(fd[1]);
            close(fd[0]);
            goto mainWhileLoop;   
        } 
            }   
            
           
        
        else{
            printf("\nAn error occurred.\n\n");
            continue;
        }
        
        
    }
    return 0;
}