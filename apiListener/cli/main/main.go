package main

import (
	//"context"
	//"fmt"
	//"encoding/json"
	"net/http"
	pdtapi "productPriceTrackerAPI/pkg/productpricetracker_api"
	"cloud.google.com/go/firestore"
	"firebase.google.com/go/v4/auth"
	"github.com/gin-gonic/gin"
)

const (
	firebaseConfigFile = "firebaseadminSDK.json"
)


//auth middleware
func authMiddleware(auth *auth.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		//get the token from the header
		token := c.GetHeader("X-Authorization-Token")
		//verify the token
		_, err := auth.VerifyIDToken(c, token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"error": "unauthorized",
			})
			c.Abort()
			return
		}
		c.Next()
	}
}

//get all products handler
func getAllProductsHandler(db *firestore.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		//get all products from the db
		products, err := pdtapi.GetProducts(db)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "error getting products",
			})
			return
		}
		c.JSON(http.StatusOK, products)
	}
}

//post tracking request handler



func postTrackingRequestHandler(db *firestore.Client) gin.HandlerFunc {
	return func(c *gin.Context) {

		var req pdtapi.TrackingRequest //init the request struct
		err := c.BindJSON(&req) //bind the request body to the request struct
		if err != nil { //check if error during the binding
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "could not parse request body",
			}) //return bad request (HTTP 400)
			return
		}

		if len(req.ProductIDs) == 0 { //check if no product ids are provided
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "product_ids is required",
			}) //return bad request (HTTP 400)
			return
		}

		if !req.IsEmail && !req.IsWhatsApp && !req.IsTelegram && !req.IsSMS { //check if no notification method is provided
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "at least one notification method is required",
			}) //return bad request (HTTP 400)
			return
		}

		if req.IsEmail && req.Email == "" { //check if email is required but not provided
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "email is required to send email notifications",
			}) //return bad request (HTTP 400)
			return
		} else if !pdtapi.CheckEmail(req.Email) { //check if email is valid
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "invalid email",
			}) //return bad request (HTTP 400)
			return
		}

		if (req.IsWhatsApp || req.IsSMS || req.IsTelegram) && req.Phone == "" { //check if phone number is required but not provided
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "phone is required to send whatsapp/sms/telegram notifications",
			}) //return bad request (HTTP 400)
			return
		} else if !pdtapi.CheckPhone(req.Phone) { //check if phone number is valid
			c.JSON(http.StatusBadRequest, gin.H{
				"error": "invalid phone number",
			}) //return bad request (HTTP 400)
			return
		}

		//check if the product ids are in the db
		products, err := pdtapi.GetProducts(db)


		for _, id := range req.ProductIDs {
			found := false
			inner:
				for _, product := range products {
					if product.ID == id {
						found = true
						break inner
					}
				}	
			if !found {
				c.JSON(http.StatusBadRequest, gin.H{
					"error": "product id not found",
				}) //return bad request (HTTP 400)
				return
			}
		}

		//add the tracking request to the db
		err = pdtapi.AddTrackingRequest(db, req)
		
	}
}

//setup the router

func setupRouter(db *firestore.Client, auth *auth.Client) *gin.Engine {
	//init the router
	r := gin.Default()
	//setup the routes
	r.GET("/products", getAllProductsHandler(db))
	r.POST("/tracking", authMiddleware(auth), postTrackingRequestHandler(db))
	return r
}

func main() {
	//init the firebase app
	app := pdtapi.InitFirebaseApp(firebaseConfigFile)
	db := pdtapi.InitFirestore(app)
	auth := pdtapi.InitFirebaseAuth(app)
	//setup the router
	r := setupRouter(db, auth)
	//run the server
	r.Run(":8080")
}

