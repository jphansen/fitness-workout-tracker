import requests
import json

BASE_URL = "http://localhost:8888"

def test_auth():
    print("Testing authentication system...")
    
    # Test 1: Register a new user
    print("\n1. Testing user registration...")
    register_data = {
        "username": "testuser",
        "password": "test123",
        "email": "test@example.com",
        "full_name": "Test User"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/auth/register", json=register_data)
        print(f"   Status: {response.status_code}")
        if response.status_code == 201:
            print("   ✓ Registration successful")
            user_data = response.json()
            print(f"   User ID: {user_data.get('_id')}")
        elif response.status_code == 400:
            error_data = response.json()
            print(f"   ✗ Registration failed: {error_data.get('detail')}")
            if "already registered" in error_data.get('detail', ''):
                print("   User already exists, continuing with login...")
        else:
            print(f"   ✗ Unexpected status: {response.status_code}")
            print(f"   Response: {response.text}")
    except Exception as e:
        print(f"   ✗ Error during registration: {e}")
    
    # Test 2: Login
    print("\n2. Testing user login...")
    login_data = {
        "username": "testuser",
        "password": "test123"
    }
    
    try:
        response = requests.post(f"{BASE_URL}/auth/login", json=login_data)
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            token_data = response.json()
            access_token = token_data.get('access_token')
            print("   ✓ Login successful")
            print(f"   Token type: {token_data.get('token_type')}")
            print(f"   Access token: {access_token[:50]}...")
            
            # Test 3: Get current user info
            print("\n3. Testing get current user info...")
            headers = {"Authorization": f"Bearer {access_token}"}
            response = requests.get(f"{BASE_URL}/auth/me", headers=headers)
            print(f"   Status: {response.status_code}")
            if response.status_code == 200:
                user_info = response.json()
                print("   ✓ User info retrieved")
                print(f"   Username: {user_info.get('username')}")
                print(f"   Email: {user_info.get('email')}")
            else:
                print(f"   ✗ Failed to get user info: {response.status_code}")
                print(f"   Response: {response.text}")
            
            # Test 4: Test protected workout endpoints
            print("\n4. Testing protected workout endpoints...")
            
            # Get workouts (should return empty list for new user)
            response = requests.get(f"{BASE_URL}/workouts/", headers=headers)
            print(f"   GET /workouts status: {response.status_code}")
            if response.status_code == 200:
                workouts = response.json()
                print(f"   ✓ Retrieved {len(workouts)} workouts")
            else:
                print(f"   ✗ Failed to get workouts: {response.status_code}")
                print(f"   Response: {response.text}")
            
            # Test 5: Test protected template endpoints
            print("\n5. Testing protected template endpoints...")
            response = requests.get(f"{BASE_URL}/templates/", headers=headers)
            print(f"   GET /templates status: {response.status_code}")
            if response.status_code == 200:
                templates = response.json()
                print(f"   ✓ Retrieved {len(templates)} templates")
            else:
                print(f"   ✗ Failed to get templates: {response.status_code}")
                print(f"   Response: {response.text}")
            
            # Test 6: Test without authentication (should fail)
            print("\n6. Testing without authentication (should fail)...")
            response = requests.get(f"{BASE_URL}/workouts/")
            print(f"   GET /workouts without auth status: {response.status_code}")
            if response.status_code == 401:
                print("   ✓ Correctly rejected unauthorized access")
            else:
                print(f"   ✗ Unexpected status: {response.status_code}")
            
        else:
            print(f"   ✗ Login failed: {response.status_code}")
            print(f"   Response: {response.text}")
    except Exception as e:
        print(f"   ✗ Error during login: {e}")
    
    print("\n" + "="*50)
    print("Authentication test completed!")

if __name__ == "__main__":
    test_auth()
