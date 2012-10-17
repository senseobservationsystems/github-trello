# encoding: utf-8

require 'spec_helper'

describe Github::Authorization do
  let(:client_id) { '234jl23j4l23j4l' }
  let(:client_secret) { 'asasd79sdf9a7asfd7sfd97s' }
  let(:code) { 'c9798sdf97df98ds'}
  let(:github) {
    Github.new :client_id => client_id, :client_secret => client_secret
  }

  after do
    github.client_id, github.client_secret = nil, nil
    reset_authentication_for github
  end

  context '.client' do
    it { github.should respond_to :client }

    it "should return OAuth2::Client instance" do
      github.client.should be_a OAuth2::Client
    end

    it "should assign site from the options hash" do
      github.client.site.should == 'https://github.com'
    end

    it "should assign 'authorize_url" do
      github.client.authorize_url.should == 'https://github.com/login/oauth/authorize'
    end

    it "should assign 'token_url" do
      github.client.token_url.should == 'https://github.com/login/oauth/access_token'
    end
  end

  context '.auth_code' do
    let(:oauth) { OAuth2::Client.new(client_id, client_secret) }

    it "should throw an error if no client_id" do
      github.client_id = nil
      expect { github.auth_code }.should raise_error(ArgumentError)
    end

    it "should throw an error if no client_secret" do
      github.client_secret = nil
      expect { github.auth_code }.should raise_error(ArgumentError)
    end

    it "should return authentication token code" do
      github.client_id = client_id
      github.client_secret = client_secret
      github.client.stub(:auth_code).and_return code
      github.auth_code.should == code
    end
  end

  context "authorize_url" do
    it "should respond to 'authorize_url' " do
      github.should respond_to :authorize_url
    end

    it "should return address containing client_id" do
      github.authorize_url.should =~ /client_id=#{client_id}/
    end

    it "should return address containing scopes" do
      github.authorize_url(:scope => 'user').should =~ /scope=user/
    end

    it "should return address containing redirect_uri" do
      github.authorize_url(:redirect_uri => 'http://localhost').should =~ /redirect_uri/
    end
  end

  context "get_token" do
    before do
      stub_request(:post, 'https://github.com/login/oauth/access_token').
        to_return(:body => '', :status => 200, :headers => {})
    end

    it "should respond to 'get_token' " do
      github.should respond_to :get_token
    end

    it "should make the authorization request" do
      expect {
        github.get_token code
        a_request(:post, "https://github.com/login/oauth/access_token").should have_been_made
      }.to raise_error(OAuth2::Error)
    end

    it "should fail to get_token without authorization code" do
      expect { github.get_token }.to raise_error(ArgumentError)
    end
  end

  context ".authenticated?" do
    it { github.should respond_to :authenticated? }

    it "should return false if falied on basic authentication" do
      github.stub(:basic_authed?).and_return false
      github.authenticated?.should be_false
    end

    it "should return true if basic authentication performed" do
      github.stub(:basic_authed?).and_return true
      github.authenticated?.should be_true
    end

    it "should return true if basic authentication performed" do
      github.stub(:oauth_token?).and_return true
      github.authenticated?.should be_true
    end
  end

  context ".basic_authed?" do
    before do
      github.stub(:basic_auth?).and_return false
    end

    it { github.should respond_to :basic_authed? }

    it "should return false if login is missing" do
      github.stub(:login?).and_return false
      github.basic_authed?.should be_false
    end

    it "should return true if login && password provided" do
      github.stub(:login?).and_return true
      github.stub(:password?).and_return true
      github.basic_authed?.should be_true
    end
  end

  context "authentication" do
    it "should respond to 'authentication'" do
      github.should respond_to :authentication
    end

    it "should return empty hash if no basic authentication params available" do
      github.stub(:login?).and_return false
      github.stub(:basic_auth?).and_return false
      github.authentication.should be_empty
    end

    context 'basic_auth' do
      before do
        github = Github.new :basic_auth => 'github:pass'
      end

      it "should return hash with basic auth params" do
        github.authentication.should be_a Hash
        github.authentication.should have_key :basic_auth
      end
    end

    context 'login & password' do
      before do
        github = Github.new :login => 'github', :password => 'pass'
        github.basic_auth = nil
      end

      it "should return hash with login & password params" do
        github.authentication.should be_a Hash
        github.authentication.should have_key :login
      end
    end
  end # authentication

end # Github::Authorization
