package productpricetracker_api
import (
	"context"
	"log"
	firebase "firebase.google.com/go/v4"
	"google.golang.org/api/option"
	"firebase.google.com/go/v4/auth"
	"cloud.google.com/go/firestore"
)

//init the firebase app
func InitFirebaseApp(firebaseConfigFile string) *firebase.App {
	ctx := context.Background() //init the context for the app
	app, err := firebase.NewApp(ctx, nil, option.WithCredentialsFile(firebaseConfigFile)) //init the app with the config file
	if err != nil { //check if error during the app init
		log.Fatalf("error initializing app: %v\n", err)
	}
	return app
}

func InitFirestore(app *firebase.App) *firestore.Client {
	ctx := context.Background() //init the context for the app
	client, err := app.Firestore(ctx) //init the firestore client
	if err != nil { //check if error during the client init
		log.Fatalf("error initializing firestore client: %v\n", err)
	}
	return client
}

func InitFirebaseAuth(app *firebase.App) *auth.Client {
	ctx := context.Background() //init the context for the app
	client, err := app.Auth(ctx) //init the auth client
	if err != nil { //check if error during the client init
		log.Fatalf("error initializing auth client: %v\n", err)
	}
	return client
}