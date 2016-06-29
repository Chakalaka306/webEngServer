class UsersController < ApplicationController

  # anmelden eines registrierten benutzers
  def register
    @user = User.find_by(login: params[:login])

    if @user.nil?
      # return status 400
      head 400
    else
      render json: @user.to_json(only: %w(salt_masterkey privkey_user_enc pubkey_user))
    end
  end
# anlegegen eines neuen benutzers
  def create
    @user = User.new(login: params[:login],
                     salt_masterkey: params[:salt_masterkey],
                     pubkey_user: params[:pubkey_user],
                     privkey_user_enc: params[:privkey_user_enc])

    if @user.save
      head 201
    else
      head 400
    end
  end
# user loeschen
  def destroy
    user = User.check_sig(params[:timestamp].to_s, params[:login], params[:digitale_signatur])
    if user.nil?
      head 400
    else
      user.destroy
      head 200
    end
  end
# anfordnern des pubkeys einer benutzers
  def pubkey
    @user = User.find_by(login: params[:login])

    if @user.nil?
      head 404
    else
      render json: @user.to_json(only: %w(pubkey_user))
    end
  end
end
