package productpricetracker_api

import (
	"regexp"
	"cloud.google.com/go/firestore"
	"context"
)

type TrackingRequest struct {
	ProductIDs []string `json:"product_ids"`
	Email string `json:"email"`
	Phone string `json:"phone"`
	IsEmail bool `json:"is_email"`
	IsWhatsApp bool `json:"is_whatsapp"`
	IsTelegram bool `json:"is_telegram"`
	IsSMS bool `json:"is_sms"`
}

func CheckEmail(email string) bool {
	//check if the email is valid
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	return emailRegex.MatchString(email)
}

func CheckPhone(phone string) bool {
	//check if the phone number is valid ( 10 digits)
	phoneRegex := regexp.MustCompile(`^[0-9]{10}$`) 
	return phoneRegex.MatchString(phone)
}

func AddTrackingRequest(db *firestore.Client, trackingRequest TrackingRequest) error {
	//add the tracking request to the db
	ctx := context.Background()
	_, _, err := db.Collection("tracking_requests").Add(ctx, trackingRequest)
	if err != nil {
		return err
	}
	return nil
}