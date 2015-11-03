$(document).ready(function() {
  playerHits();
  playerStays();
  dealerHits();
});

function playerHits() {
$(document).on('click', '#hit_form input', function() {
  $.ajax({
    type: 'POST',
    url: '/game/player/hit'
  }).done(function(msg){
    $('#game').replaceWith(msg);
  });
  return false;
});
}

function playerStays() {
$(document).on('click', '#stay_form input', function() {
  $.ajax({
    type: 'POST',
    url: '/game/player/stay'
  }).done(function(msg){
    $('#game').replaceWith(msg);
  });
  return false;
});
}

function dealerHits() {
$(document).on('click', '#dealer_hit_form input', function() {
  $.ajax({
    type: 'POST',
    url: '/game/dealer/hit'
  }).done(function(msg){
    $('#game').replaceWith(msg);
  });
  return false;
});
}
