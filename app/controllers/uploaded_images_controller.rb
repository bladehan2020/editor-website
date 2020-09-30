class UploadedImagesController < ApplicationController
  layout "site", :except => :rss
  before_action :authorize_web
  before_action :set_locale

  authorize_resource 

  before_action :lookup_user, :only => [:show, :comments]
  before_action :allow_thirdparty_images, :only => [:new, :create, :edit, :update, :index, :show, :comments]

  def index
    if params[:display_name]
      @user = User.active.find_by(:display_name => params[:display_name])
      if @user
        @title = @user.display_name + "'s uploaded images"
      end
    end
    uri = URI.parse('http://noter-backend:3001/api/v0.1/whatdoihave/')
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Get.new(uri.path)
    req["X-Email"] = current_user.email
    res = http.request(req)
    user_has = JSON.parse(res.body)
    @images = user_has['images_by_user']
  end

  def destroy_multiple
    if params[:deleted_img_ids]
      for id in params[:deleted_img_ids] do
        uri = URI('http://noter-backend:3001/api/v0.1/images/' + id.to_s + '/')
        http = Net::HTTP.new(uri.host, uri.port)
        req = Net::HTTP::Delete.new(uri.path)
        req["X-Email"] = current_user.email
        res = http.request(req)
      end
    end
    redirect_to :action => "index", :display_name => current_user.display_name
  end
end
