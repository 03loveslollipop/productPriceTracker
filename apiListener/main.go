package main
import (
	"context"
	"fmt"
	"log"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"google.golang.org/api/option"
)

const (
	firebaseConfigFile = "firebaseConfig.json"
	firebaseBDURL = "https://api-project-1076196630000.firebaseio.com"
)

//init the firebase app
func initFirebaseApp() *firebase.App {
	ctx := context.Background() //init the context for the app
	app, err := firebase.NewApp(ctx, nil, option.WithCredentialsFile(firebaseConfigFile)) //init the app with the config file
	if err != nil { //check if error during the app init
		log.Fatalf("error initializing app: %v\n", err)
	}
}