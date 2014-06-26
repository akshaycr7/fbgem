class FacebookController < ApplicationController

before_filter :authenticate_user!

def index
  unless current_user.facebook_oauth_setting
       
        @oauth = Koala::Facebook::OAuth.new("1519573828266300", "4fcd4a6d92d3146448d647d69dd3e0a8", "http://localhost:3000/callback")
        session["oauth_obj"] = @oauth
        redirect_to @oauth.url_for_oauth_code(:scope => 'user_friends, user_photos, user_videos')
    else
       redirect_to "/facebook_profile"
    end
end

def callback

  unless current_user.facebook_oauth_setting
        @oauth = session["oauth_obj"]
        FacebookOauthSetting.create({:access_token => @oauth.get_access_token(params[:code]), :user_id => current_user.id})
        redirect_to "/facebook_profile"
    # else
        # redirect_to "/facebook_profile"
    end
end

def facebook_profile
    
  if current_user.facebook_oauth_setting
        @graph = Koala::Facebook::API.new(current_user.facebook_oauth_setting.access_token)
        @profile = @graph.get_object("me")
        @picture = @graph.get_picture("me")
        @feed = @graph.get_connections("me","feed")
        @friends = @graph.get_connections("me", "friends")
        @statuses = @graph.get_connections("me","statuses")
        @links = @graph.get_connections("me","links")
        
    else
        redirect_to "/"
    end
end

end
