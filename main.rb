require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'mystringabc'
helpers do

  def calculate_total(cards)
    arr = cards.map{|e| e[1]}

    total = 0
    arr.each do |value|
      if value == "Ace"
        total += 11
      elsif value.to_i == 0
        total += 10
      else
        total += value.to_i
      end
    end

      arr.select{|e| e == "Ace"}.count.times do
        if total > 21
          total -= 10
        end
      end

      total
  end

  def card_image(card)
    suit = case card[0]
      when 'H' then 'hearts'
      when 'C' then 'clubs'
      when 'D' then 'diamonds'
      when 'S' then 'spades'
    end

    value = card[1] 
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card'>"

  end

end

before do
  @show_hit_or_stay_buttons = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required."
    halt erb :new_player
  end

  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  suits = ["H", "S", "D", "C"]
  values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
  session[:deck] = suits.product(values).shuffle!

  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  player_total = calculate_total(session[:player_cards])
  if player_total == 21
    @success = "Congratulations, #{session[:player_name]} hit blackjack! #{session[:player_name]} wins!"
    @show_hit_or_stay_buttons = false
  elsif player_total > 21
    @error = "Sorry, it looks like #{session[:player_name]} busted."
    @show_hit_or_stay_buttons = false
  end

  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay."
  @show_hit_or_stay_buttons = false

  erb :game
end

get '/dealer'
  dealer_total = calculate_total(session[:player_cards])
  begin
    session[:dealer_cards] << session[:deck].pop
  end until dealer_total > 17
  if dealer_total == 21
    @error = "Sorry, Dealer hit blackjack! Dealer wins."
  elsif dealer_total > 21
    @success = "Dealer busted. #{session[:player_name]} wins!"
  elsif dealer_total > player_total
    @error = "Sorry, Dealer has a higher total than #{session[:player_name]}. Dealer wins."
  elsif dealer_total < player_total
    @success = "Dealer has a lower total than #{session[:player_name]}. #{session[:player_name]} wins!"
  end
  @show_hit_or_stay_buttons = false
end





