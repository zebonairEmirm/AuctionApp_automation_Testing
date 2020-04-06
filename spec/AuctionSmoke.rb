require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'rspec'
require 'faker'


Capybara.default_driver = :selenium_chrome
Capybara.ignore_hidden_elements = false


RSpec.describe 'Auction Smoke', type: :feature do

  before(:each) do

    page.driver.browser.manage.window.maximize #fullscreen mode
    visit 'https://auction-app-rf.herokuapp.com/'
    #Essential to login on every case 
    #Loging in with premade account

      find(:xpath, '//*[@id="root"]/div/div[1]/div/span[2]/a[1]').click
      sleep(3)
  
      fill_in 'email', with: 'cashmoney@testmail.com'
      fill_in 'password', with: 'corona2020'
      find_button('Login').click
      sleep(3) 
      expect(page).to have_text('Logout')
  end
  
 
  it 'Search for a product' do
    productSearch = find(:xpath, '//*[@id="root"]/div/nav/div/div/input').set 'Lenovo A7000'
    productSearch.native.send_keys(:return)
    expect(page).to have_text('Lenovo A7000')
    expect(page).to have_text('Starts from $400.00')
    sleep(3)
  end

  it 'Bid on an item' do 
    #navigating to featured sections and hovering one of the items
    find(:xpath, '//*[@id="root"]/div/div[3]/div[1]/div[2]/div[2]/div').hover #

    #within the div of the item, find the bidding button
    within :xpath, '//*[@id="root"]/div/div[3]/div[1]/div[2]/div[2]/div' do
      find_button('Bid').click
    end

    #Since the highest bid will change after each test run, it is important to increment the bid value on each new test
    #The following block of code increments the value of a bid input until its the highest bid 
    #I've used exception handling to make the case pass 
    bid = 609 #setting price as a variable
    within '.ProductDetails_productDetails__WoTbJ' do  #within the div where the bidding form is
      begin #Try-catch method basically
        find(:xpath, '//*[@id="root"]/div/div[3]/div[2]/input').set bid #setting the bid
        find_button('Place Bid').click
        sleep(3) #waiting for the alert box to pop up since the bid price is 
        while true do #The loop will run until it reaches the highes bid 
          alert = page.driver.browser.switch_to.alert #notice the alert
          alert.accept #click OK
          bid = bid + 1 #increment the bid 
          find(:xpath, '//*[@id="root"]/div/div[3]/div[2]/input').set bid #set the new bid value in input
          find_button('Place Bid').click
          sleep(3)
        end
      rescue Selenium::WebDriver::Error::NoSuchAlertError #this error is expected, hence the exception on it 
      end
    end
  end


  #I can generate new account with the same inputs for now
  it 'Logs out the current account then creates new account' do

    #Log out
    find(:xpath, '//*[@id="root"]/div/div[1]/div/span[2]/a').click
    sleep(2)
    expect(page).to have_text 'Login'
    expect(page).to have_text 'Create new account'

    #Create new
    find(:xpath, '//*[@id="root"]/div/div[1]/div/span[2]/a[2]').click

    #using faker for random generated mails
    find_field('firstName').set Faker::Name.first_name
    find_field('lastName').set Faker::Name.last_name
    find_field('email').set Faker::Internet.email
    find_field('password').set '12345' #Same password for all these generated user 
    sleep(2)
    find_button('Register').click  
    sleep(3)
    expect(page).to have_text('Logout')
    sleep(3)
  end
end 