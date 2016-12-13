=begin

 Hello Netguru employee!

 I took liberty of writing specs for Modern Library ( application used in recruitment process ) using Rspec with Capybara.
 I hope you don't mind. I decided to provide code in a single file, so it can be executed with default version of spec_helper.
 I am not familiar with Page Object Model yet (but I am eager to learn!). 

 There should be 8 FAILURES. Each failure is actually a bug.
 Every bug got its own comment below examples' code.

 Created by Kamil Ścisło
 
 Development environment:
 - OS: Windows 7 SP1
 - Browser: Chrome 55.0.2883.75
 - Text editor: Sublime Text
 - Ruby 2.3.1p112
                             
=end

require 'capybara/rspec'
require 'selenium-webdriver'
require 'spec_helper'

Capybara.default_driver = :selenium
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

#List of variables used by examples   
valid_email = 'TEST2016-12Junior@gmail.com' 
valid_password = 'p@ssword'
invalid_email = 'TESTagmail.com' 
invalid_password = 'p@sswor'
testing_email = 'TEST2016@gmail.com'
used_email = 'TEST_used@gmail.com' 
#End of the list  

def staging_authentication 
  page.driver.browser.manage.window.maximize #resize_to(1920, 1080)
  visit 'http://qa-workshop.staging.devguru.co/' 
  fill_in 'code', with: 'biedronka'
  find_button('Sign in').click
end
    
def log_in
  testing_email = 'TEST2016@gmail.com'
  valid_password = 'p@ssword'
  visit 'http://qa-workshop.staging.devguru.co/users/sign_in'
  fill_in 'Email', with: testing_email
  fill_in 'Password', with: valid_password
  click_button 'Log in'
end

def destroy_order
  visit 'http://qa-workshop.staging.devguru.co/'    
  find_link('Order now').click
  visit 'http://qa-workshop.staging.devguru.co/orders'
  find_link('Destroy').click
  page.driver.browser.switch_to.alert.accept
end

describe 'Navigation bar links:', :type => :feature do
  before do  
    staging_authentication 
  end
  
  it 'Modern Library' do
    find_link('Modern Library').click
    sleep 1
    expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/'
  end 

  it 'About us' do
    find_link('About us').click
    sleep 1
    expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/about_us'
    # this example should FAIL as 'About Us' link redirects to home page.
  end

  it 'Search' do
    find_link('Search').click
    sleep 1
    expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/search'
    # this example should FAIL as 'Search' link is misspelled.
  end 

  it 'Contact' do
    find_link('Contact').click
    sleep 1
    expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/contact_requests/new'
  end

  it 'Sign up' do
    within(:xpath, "//*[@class='nav navbar-nav navbar-right']") do
      find_link('Sign up').click
      sleep 1
      expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/users/sign_up'
    end
  end 

  it 'Sign in' do
    within(:xpath, "//*[@class='nav navbar-nav navbar-right']") do
      find_link('Sign in').click
      sleep 1
      expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/users/sign_in'
    end
  end

  it 'Your bookshelf [link inside drop-down list]' do
    visit 'http://qa-workshop.staging.devguru.co/users/sign_in'
    fill_in 'Email', with: testing_email
    fill_in 'Password', with: valid_password
    click_button 'Log in'
    find(:xpath, '//*[@class="dropdown-toggle"]').click
    find_link('Your bookshelf').click
    expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/carts'
    # this example should FAIL as 'Your bookshelf' link redirects to Orders page.
  end

  it 'Your orders [link inside drop-down list]' do  
    visit 'http://qa-workshop.staging.devguru.co/users/sign_in'
    fill_in 'Email', with: testing_email
    fill_in 'Password', with: valid_password
    click_button 'Log in'
    find(:xpath, '//*[@class="dropdown-toggle"]').click
    find_link('Your orders').click
    expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/orders'
    # this example should FAIL as 'Your orders' link redirects to Your bookshelf page.
  end 

  it 'Sign out [link inside drop-down list]' do
    visit 'http://qa-workshop.staging.devguru.co/users/sign_in'
    fill_in 'Email', with: testing_email
    fill_in 'Password', with: valid_password
    click_button 'Log in'
    find(:xpath, '//*[@class="dropdown-toggle"]').click
    find_link('Sign out').click
    expect(page).to have_content 'Signed out successfully.'
  end
end

describe 'Links in "Your shelf":', :type => :feature do
  before do
    staging_authentication 
  end

  it 'LOG IN' do
    within(:xpath, '//*[@class="col-md-4"]') do
      find_link('Log in').click
      sleep 1
      expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/users/sign_in'
    end
  end

  it 'SIGN UP' do
    within(:xpath, "//*[@class='col-md-4']") do
      find_link('Sign up').click
      sleep 1
      expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/users/sign_up'
    end
  end
end

describe 'Creating new account: ', :type => :feature do
  before do
    staging_authentication 
    visit 'http://qa-workshop.staging.devguru.co/users/sign_up'
  end
  
  it 'with valid email + valid password [ Happy path ]' do
    fill_in ' Email', with: valid_email
    fill_in 'user_password', with: valid_password  
    fill_in ' Password confirmation', with: valid_password    
    click_button 'Sign up'   
    expect(page).to have_content("Welcome! You have signed up successfully")    
  end

  it 'with invalid email (email address without @ symbol ) + valid password' do
    fill_in ' Email', with: invalid_email
    fill_in 'user_password', with: valid_password  
    fill_in ' Password confirmation', with: valid_password    
    click_button 'Sign up'   
    expect(page).to have_content("is invalid")    
  end

  it 'with already used email + valid password' do
    fill_in ' Email', with: used_email
    fill_in 'user_password', with: valid_password  
    fill_in ' Password confirmation', with: valid_password    
    click_button 'Sign up'   
    expect(page).to have_content("has already been taken")    
  end

  it 'with password which is too short' do
    fill_in ' Email', with: valid_email
    fill_in 'user_password', with: invalid_password  
    fill_in ' Password confirmation', with: invalid_password    
    click_button 'Sign up'   
    expect(page).to have_content("is too short (minimum is 8 characters)")    
  end

  it 'with different input values for password and confirm password fields' do
    fill_in ' Email', with: valid_email
    fill_in 'user_password', with: valid_password  
    fill_in ' Password confirmation', with: invalid_password    
    click_button 'Sign up'   
    expect(page).to have_content("doesn't match Password")    
  end

  it 'log in link (below SIGN UP)' do
    find_link('Log in').click
    sleep 1
    expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/users/sign_in'  
  end 
end

describe 'Logging in', :type => :feature do 
  before do
    staging_authentication 
    visit 'http://qa-workshop.staging.devguru.co/users/sign_in'
  end
   
  it 'with valid email + valid password [Happy path]' do
    fill_in 'Email', with: testing_email
    fill_in 'Password', with: valid_password
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully.'
  end

  it 'with valid email + invalid password' do
    fill_in 'Email', with: testing_email
    fill_in 'Password', with: invalid_password
    click_button 'Log in'
    expect(page).to have_content 'Invalid email or password.'
  end
  
  it 'with invalid email + valid password' do
    fill_in 'Email', with: invalid_email
    fill_in 'Password', with: valid_password
    click_button 'Log in'
    expect(page).to have_content 'Invalid email or password.'
  end

  it 'with invalid email + invalid password' do
    fill_in 'Email', with: invalid_email
    fill_in 'Password', with: invalid_password
    click_button 'Log in'
    expect(page).to have_content 'Invalid email or password.'
  end

  it 'with "Remember me" checkbox checked' do
    fill_in 'Email', with: testing_email
    fill_in 'Password', with: valid_password
    check 'Remember me'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully.'
    # This example should FAIL as there is no checkbox to check.
  end

  it 'Sign up link (below LOG IN)' do
    within(:xpath, "//*[@class='col-sm-4']") do
      find_link('Sign up').click
      sleep 1
      expect(current_url).to eq 'http://qa-workshop.staging.devguru.co/users/sign_up' 
    end
  end
end

describe 'Features: ', :type => :feature, js: true do
  before do
    staging_authentication 
    log_in
  end

  after do |failure|
  if failure.exception
    destroy_order
    end
  end

  it 'Your bookshelf counter' do                                                                
    find(:xpath, "(//a[text()='Add to shelf'])[1]").click     
    expect(page.body).to have_content 'Your bookshelf ( 1 )'
    destroy_order
  end 

   it 'Your bookshelf counter value after removing book from Your bookshelf' do             
    find(:xpath, "(//a[text()='Add to shelf'])[1]").click
    find_link('Remove from bookshelf').click
    expect(page.body).to have_content('Your bookshelf ( 0 )')
    # This example should FAIL as Your bookshelf counter still displays ( 1 ), but counter should display ( 0 ) .
  end

  it 'Removing book from Your bookshelf' do                                                  
    find(:xpath, "(//a[text()='Add to shelf'])[1]").click
    find_link('Remove from bookshelf').click
    visit 'http://qa-workshop.staging.devguru.co/carts'
    expect(page.body).to have_content("There aren't any books available right now. Please, check again later.")
    #this example should FAIL as book is still present in Your bookshelf page 
  end
    
  it 'Adding book to Your bookshelf [Happy path]' do                                               
    find(:xpath, "(//a[text()='Add to shelf'])[1]").click
    visit 'http://qa-workshop.staging.devguru.co/carts'
    expect(page).to have_xpath("//*[@class='book panel panel-material-light-green']")  
    destroy_order
  end

  it '"Book added to Your bookshelf!" message after adding new book to Your bookshelf' do         
    find(:xpath, "(//a[text()='Add to shelf'])[1]").click
    expect(page.body).to have_content 'Book added to Your bookshelf!'
    # This example should FAIL as "Book added to Your bookshelf!" message is not displayed. Message that appears: 'Book removed from cart!'
  end

  it 'Creating an Order' do                                                                         
    find(:xpath, "(//a[text()='Add to shelf'])[1]").click  
    within(:xpath, "//*[@class='panel panel-material-light-green']") do 
      find_link('Order now').click
    end
    expect(page).to have_content('Order was successfully created.')
    visit 'http://qa-workshop.staging.devguru.co/orders'
    find_link('Destroy').click
    page.driver.browser.switch_to.alert.accept
  end

  it '"Book removed from cart!" message after removing book from Your bookshelf' do             
    find(:xpath, "(//a[text()='Add to shelf'])[1]").click
    find_link('Remove from bookshelf').click
    expect(page.body).to have_content('Book removed from cart!')
    destroy_order
  end

  it 'Listing ordered books in Orders page' do                                                 
    find(:xpath, "(//a[text()='Add to shelf'])[1]").click  
    find_link('Order now').click
    within(:xpath, '//*[@class="table table-hover table-striped"]') do
      expect(page).to have_xpath(".//td", :count => 3) 
    end
    visit 'http://qa-workshop.staging.devguru.co/orders'
    find_link('Destroy').click
    page.driver.browser.switch_to.alert.accept
  end

  it "Destroying book's order in Orders page" do                                               
    find(:xpath, "(//a[text()='Add to shelf'])[1]").click  
    destroy_order
    expect(page).to have_content 'Order was successfully destroyed.'
  end
end


