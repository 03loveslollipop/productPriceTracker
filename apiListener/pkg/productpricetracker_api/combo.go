package productpricetracker_api

import (
	"context"
	//"errors"
	//"fmt"
	"cloud.google.com/go/firestore"
	iterator "google.golang.org/api/iterator"
)

type Combo struct {
	ID string `json:"id"`
	Name string `json:"name"`
	ProductCount uint64 `json:"product_count"`
	Products []uint64 `json:"products"`
	Description string `json:"description"`
	CurrentPrice float64 `json:"current_price"`
	StdPrice float64 `json:"std_price"`
}

func parseCombo(rawData map[string]interface{}, id string) (Product,error) {

	var currentprice, stdprice, discount float64
	var size uint64
	var err error

	currentprice, err = toFloat64(rawData["current_price"])
	if err != nil {
		return Product{}, err
	}
	stdprice, err = toFloat64(rawData["std_price"])
	if err != nil {
		return Product{}, err
	}
	discount, err = toFloat64(rawData["discount"])
	if err != nil {
		return Product{}, err
	}
	
	size, err = toUint64(rawData["product_size"])
	if err != nil {
		return Product{}, err
	}



	product := Product{
		ID: id,
		Name: rawData["name"].(string),
		CurrentPrice: currentprice,
		StdPrice: stdprice,
		Discount: discount,
		Size: size,
		SizeDimention: rawData["product_unit"].(string),
		Description: rawData["description"].(string),
	}
	return product, nil
}

func GetCombo(db *firestore.Client) ([]Product, error) {
	//get all products from the db
	ctx := context.Background()
	result := db.Collection("products").Documents(ctx)
	ResultList := []Product{}
	for{
		doc, err := result.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, err
		}
		rawData := doc.Data() //get the raw data from the document
		id := doc.Ref.ID

		parsed, err := parseProduct(rawData, id)
		if err != nil {
			return nil, err
		}
		ResultList = append(ResultList, parsed)
	}
	return ResultList, nil
}
