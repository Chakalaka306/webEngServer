# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(login: "Dominik", salt_masterkey: "master", pubkey_user: "pub", privkey_user_enc: "crypt_privkey")
Message.new(recipient: "empfanger", content_enc: "text", sender: "sender",
            iv: "iv", key_recipient_enc: "params[:key_recipient_enc]", sig_recipient: "params[:sig_recipient]",
            sig_service: "params[:sig_service]")