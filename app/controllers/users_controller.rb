class UsersController < ApplicationController

  def anmelden
    @user = User.find_by(login: params[:login])

    if @user.nil?
      # return status 400
      head 400
    else
      render json: @user.to_json(only: %w(salt_masterkey privkey_user_enc pubkey_user))
    end
  end

  def create
    @user = User.new(login: params[:login], salt_masterkey: params[:salt_masterkey], pubkey_user: params[:pubkey_user], privkey_user_enc: params[:privkey_user_enc])

    if @user.save
      head 201
    else
      head 400
    end
  end

  def pubkey
    @user = User.find_by(login: params[:login])

    if @user.nil?
      head 404
    else
      render json: @user.to_json(only: %w(pubkey_user))
    end
  end

  def destroy
    user = User.check_sig(params[:timestamp].to_s, params[:login], params[:digitale_signatur])

    user.destroy

    head 200
  end
end
