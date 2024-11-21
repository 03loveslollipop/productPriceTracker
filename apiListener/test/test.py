import requests
import json
import random

url = 'http://localhost:8080'
products = []


# get all products
def get_products():
    response = requests.get(url + '/products')
    return response.json()

'''
type TrackingRequest struct {
	ProductIDs []string `json:"product_ids"`
	Email string `json:"email"`
	Phone string `json:"phone"`
	IsEmail bool `json:"is_email"`
	IsWhatsApp bool `json:"is_whatsapp"`
	IsTelegram bool `json:"is_telegram"`
	IsSMS bool `json:"is_sms"`
}
'''

def create_track_request(product_ids, email, phone, is_email, is_whatsapp, is_telegram, is_sms):
    data = {
        "product_ids": product_ids,
        "email": email,
        "phone": phone,
        "is_email": is_email,
        "is_whatsapp": is_whatsapp,
        "is_telegram": is_telegram,
        "is_sms": is_sms
    }
    response = requests.post(url + '/tracking', json=data, headers={'X-Authorization-Token': 'debug'})
    return response.json()

def test_get_products():
    global products
    print('Testing get_products')
    products = get_products()
    print(products)
    assert len(products) > 0
    
def test_create_track_request():
    print('Testing create_track_request')
    product_ids = [products[0]['id']]
    email = f"{str.join("",random.sample('abcdefghijklmnopqrstuvwxyz', 10))}@test.com"
    phone = f"{str.join("",random.sample('1234567890', 10))}"
    is_email = random.choice([True, False])
    is_whatsapp = random.choice([True, False])
    is_telegram = random.choice([True, False])
    is_sms = random.choice([True, False])
    if not is_email and not is_whatsapp and not is_telegram and not is_sms:
        rand = random.choice([1,2,3,4])
        if rand == 1:
            is_email = True
        elif rand == 2:
            is_whatsapp = True
        elif rand == 3:
            is_telegram = True
        else:
            is_sms = True
    response = create_track_request(product_ids, email, phone, is_email, is_whatsapp, is_telegram, is_sms)
    print(response)

def main():
    print('Running tests')
    test_get_products()
    test_create_track_request()   
    
if __name__ == '__main__':
    main()