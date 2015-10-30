require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'mystringabc'

BLACKJACK_AMOUNT = 21
DEALER_HIT_MIN = 17

helpers do

  def calculate_total(cards)
    arr = cards.map{|e| e[1]}

    total = 0
    arr.each do |value|
      if value == "A"
        total += 11
      elsif value.to_i == 0
        total += 10
      else
        total += value.to_i
      end
    end

      arr.select{|e| e == "Ace"}.count.times do
        if total > BLACKJACK_AMOUNT
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

  def winner!(msg)
    @show_hit_or_stay_buttons = false
    @success = msg + " #{session[:player_name]} wins!"
  end

  def loser!(msg)
    @show_hit_or_stay_buttons = false
    @error = msg + " #{session[:player_name]} loses!"
  end

  def tie!(msg)
    @show_hit_or_stay_buttons = false
    @error = msg + " #{session[:player_name]} and dealer are tied!"
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
  session[:turn] = session[:player_name]

  suits = ["H", "S", "D", "C"]
  values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
  session[:deck] = suits.product(values).shuffle!

  session[:player_cards] = []
  session[:dealer_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit blackjack.")
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit blackjack.")
  elsif player_total > BLACKJACK_AMOUNT
    loser!("#{session[:player_name]} busted.")
  end

  erb :game
end

post '/game/player/stay' do
  redirect '/game/dealer'

end

get '/game/dealer' do
  session[:turn] = 'dealer'
  @show_hit_or_stay_buttons = false
  dealer_total = calculate_total(session[:dealer_cards])
  
  if dealer_total == BLACKJACK_AMOUNT
    loser!("Dealer hit blackjack.")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("Dealer busted.")
  elsif dealer_total >= DEALER_HIT_MIN
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect 'game/dealer'  
end

get '/game/compare' do
  @show_dealer_total = true
  dealer_total = calculate_total(session[:dealer_cards])
  player_total = calculate_total(session[:player_cards])

  if dealer_total > player_total
    loser!("Dealer's total is greater than #{session[:player_name]}'s total.")
  elsif player_total > dealer_total
    winner!("#{session[:player_name]} has the higher total.")
  elsif player_total == dealer_total
    tie!("#{session[:player_name]}'s total equals dealer's total.")
  end 

  erb :game
end





