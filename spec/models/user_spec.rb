require 'spec_helper'

describe User do
  fixtures :users, :intervals
  it 'saving fails without a name' do
    User.new(:password=>'testpw',:worktime=>0).save.should eq false
  end
  it 'saving fails without a password' do
    User.new(:name=>'testuser2',:worktime=>0).save.should eq false
  end
  it 'saving fails without a worktime' do
    User.new(:name=>'testuser2',:password=>'testpw').save.should eq false
  end
  it 'saving fails with negativ worktime' do
    User.new(:name=>'testuser2',:password=>'testpw',:worktime=>-10).save.should eq false
  end
  it 'can be saved with user, pw and worktime' do
    User.new(:name=>'testuser2',:password=>'testpw',:worktime=>0).save.should eq true
  end
  it 'authentication works with the right pw' do
    users(:testuser).authenticate('password').should eq true
  end
  it 'authentication fails with the false pw' do
    users(:testuser).authenticate('falsepassword').should eq false
  end
end