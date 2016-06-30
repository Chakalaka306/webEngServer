class MessagesController < ApplicationController
  #scope '/:login' do
    #get '/' => 'users#register'
    #post '/' => 'users#create'
    #delete '/' => 'users#destroy'
    #scope '/pubkey' do
      #  get '/' => 'users#pubkey'
    #end
    #scope '/message' do
      #  get '/' => 'messages#get_last'
      #  post '/' => 'messages#create'
      #  delete '/:id' => 'messages#destroy_single'
    #end
    #scope '/messages' do
      #  get '/' => 'messages#get_all'
      #  delete '/' => 'messages#destroy_all'
    #end
  #end

  def get_last
    # Überprüfen der Signatur an message.rb
    user = Message.check_sig(params[:timestamp].to_s, params[:login], params[:digitale_signatur])

    if user == ""
      head 404
    else
      # Gibt die letzte Nachricht im JSON Format an den Client zurück
      render json: user.messages.last.to_json(only: %w(sender content_enc iv
                                              key_recipient_enc sig_recipient id created_at))
    end

  end

  def create
    begin
      # erstellen des pubkey_user von der DB, 1. public key des senders holen.
      pub_key_sender = User.find_by(login: params[:sender]).pubkey_user
      pubkey_user = OpenSSL::PKey::RSA.new(pub_key_sender)


      # erlaubter timestamp wird überprüft
      check = false

      #aktueller timestamp und gesenderter timestap dürfen nicht mehr als 5 min auseinander liegen
      if Time.zone.now.to_i - params[:timestamp].to_i < 300
        check = true
      end
      rescue # fehler behandlung
    end

    return head 404 unless check  # falls die Bedinung nicht erfüllt dann fehler

    # empfänger der nachricht ermitteln
    recipient = User.find_by(login: params[:recipient]).id

    # Erstellen der Nachricht
    msg = Message.new(recipient: recipient, content_enc: params[:content_enc], sender: params[:sender],
                      iv: params[:iv], key_recipient_enc: params[:key_recipient_enc],
                      sig_recipient: params[:sig_recipient],
                      sig_service: params[:sig_service])

    # speichern der Nachricht in der datenbank
    if msg.save
      render nothing: true,
              status: 201
    else # wurde nachricht nicht gespeichert, wird 404 zurückgegeben
      render nothing: true ,
             status: 404
    end
  end
  # löschen nachricht per id
  def destroy_single
    user = Message.check_sig(params[:timestamp].to_s, params[:login], params[:digitale_signatur])

    if user == ""
      head 404
    else
      message = Message.find_by(id: params[:id])
      message.destroy

      render nothing: true ,  status: 200
    end
  end
  # alle nachrichten abrufen
  def get_all
    # Überprüfen der Signatur an das Model message.rb deligiert => DRY
    user = Message.check_sig(params[:timestamp].to_s, params[:login], params[:digitale_signatur])

    if user == ""
      head 404
    else
      # Gibt alle Nachrichten, beginnend mit der neuesten, im JSON Format an den Client zurück
      render json: user.messages.order('created_at desc').to_json(only: %w(sender content_enc iv key_recipient_enc sig_recipient id created_at))
    end
  end
  # alle nachrichten löschen
  def destroy_all
    user = Message.check_sig(params[:timestamp].to_s, params[:login], params[:digitale_signatur])

    if user == ""
      head 404
    else
      messages = user.messages
      messages.destroy_all

      render nothing: true ,  status: 200
    end
  end

end
