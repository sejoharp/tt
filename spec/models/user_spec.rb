require 'spec_helper'

describe User do
  it 'saving fails without a name' do
  	user = User.new
  	user.save.should eq false
  end
  it 'saving fails without a password' do
  	user = User.new
  	user.name = 'testuser2'
  	user.save.should eq false
  end
  it 'can be saved with user and pw' do
  	user = User.new
  	user.name = 'testuser2'
  	user.password = 'testpw'  	
  	user.save.should eq true
  end
  it 'can be saved with user and pw' do
  	user = User.new
  	user.name = 'testuser2'
  	user.password = 'testpw'  	
  	user.save.should eq true
  end
  it 'authentication works with the right pw' do
  	user = User.new
  	user.name = 'testuser2'
  	user.password = 'testpw'
  	user.save
  	user.authenticate('testpw').should eq true
  end
  it ' authentication fails with the false pw' do
  	user = User.new
  	user.name = 'testuser2'
  	user.password = 'testpw1'
  	user.save
  	user.authenticate('testpw').should eq false
  end
end
