% UNO in SWI-Prolog
%
%   swipl -g play uno.pl       play a match
%   swipl -g demo uno.pl       one computer-only round
%   swipl -g self_test uno.pl  rule and simulation tests
%
% Official-style rules: match color or rank, Skip, Reverse, Draw Two,
% Wild, Wild Draw Four with challenge, no stacking, UNO on the way to
% one card, 2-player Reverse sends the turn back to the same player.
% First player to the winning score takes the match.

:- set_prolog_flag(double_quotes, string).

:- use_module(library(aggregate)).
:- use_module(library(ansi_term)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- use_module(library(random)).

% ---------------------------------------------------------------------------
% Entry points
% ---------------------------------------------------------------------------

play :-
    catch(start, quit_game, emit('~nThanks for playing.~n', [])).

demo :-
    banner,
    emit('Demo round: Ada, Kurt, Grace, and Alan.~n~n', []),
    Names = ["Ada", "Kurt", "Grace", "Alan"],
    Scores = [0, 0, 0, 0],
    deal_new_round(Names, [], true, Scores, 1, 500, S0),
    play_until_over(S0, S1),
    finish_round(S1, _).

self_test :-
    set_random(seed(42)),
    set_prolog_flag(color_term, false),
    (   run_checks
    ->  writeln('All UNO tests passed.')
    ;   writeln('UNO tests failed.'),
        fail
    ).

% ---------------------------------------------------------------------------
% Match setup
% ---------------------------------------------------------------------------

start :-
    intro,
    ask_number('How many human players', 1, 1, 10, HumansN),
    MinTotal is max(2, HumansN),
    DefaultTotal is max(4, HumansN),
    ask_number('How many players in total', DefaultTotal, MinTotal, 10, Total),
    gather_human_names(HumansN, HumanNames),
    AICount is Total - HumansN,
    ai_roster(Roster),
    take_n(AICount, Roster, AINames),
    append(HumanNames, AINames, Names),
    human_indexes(HumansN, Humans),
    ask_number('Winning score', 500, 100, 5000, Target),
    emit('~nPlayers: ~w~nPlaying to ~d.~n', [Names, Target]),
    play_match(Names, Humans, true, Target).

play_match(Names, Humans, Verbose, Target) :-
    length(Names, N),
    length(Scores, N),
    maplist(=(0), Scores),
    deal_new_round(Names, Humans, Verbose, Scores, 1, Target, S0),
    match_loop(S0, Target).

match_loop(S0, Target) :-
    play_until_over(S0, S1),
    finish_round(S1, S2),
    (   match_over(S2.scores, Target, Winner)
    ->  congratulate(S2, Winner)
    ;   pause_next(S2),
        Round is S2.round + 1,
        deal_new_round(S2.names, S2.humans, S2.verbose, S2.scores, Round, Target, S3),
        match_loop(S3, Target)
    ).

match_over(Scores, Target, Winner) :-
    max_list(Scores, Max),
    Max >= Target,
    findall(I, nth0(I, Scores, Max), [Winner]).

congratulate(S, Winner) :-
    nth0(Winner, S.names, Name),
    nth0(Winner, S.scores, Score),
    player_verb(Name, wins, win, Verb),
    emit('~n~w ~w the match with ~d points.~n', [Name, Verb, Score]),
    show_scores(S).

pause_next(S) :-
    (S.humans == [] ; S.verbose \== true),
    !.
pause_next(_) :-
    prompt_line('Press Enter for the next round. ', _).

finish_round(S0, S) :-
    reveal_all(S0),
    (   S0.over == stalemate
    ->  log(S0, 'Stalemate. Nobody scores.~n', []),
        S = S0
    ;   award_points(S0, S0.over, Gained, S),
        nth0(S0.over, S0.names, Name),
        player_verb(Name, scores, score, Verb),
        log(S0, '~w ~w ~d this round.~n', [Name, Verb, Gained])
    ),
    show_scores_if(S).

award_points(S0, Winner, Gained, S) :-
    findall(P, (
        nth0(I, S0.hands, Hand),
        I =\= Winner,
        hand_points(Hand, P)
    ), Ps),
    sum_list(Ps, Gained),
    nth0(Winner, S0.scores, Old),
    New is Old + Gained,
    replace_nth0(Winner, S0.scores, New, Scores),
    S = S0.put(scores, Scores).

% ---------------------------------------------------------------------------
% Deal and opening card
% ---------------------------------------------------------------------------

deal_new_round(Names, Humans, Verbose, Scores, Round, Target, S) :-
    full_deck(Deck0),
    random_permutation(Deck0, Deck1),
    deal_hands(Names, 7, Deck1, Hands, Deck2),
    pick_opening(Deck2, Top, Deck3),
    S0 = state{
        names: Names,
        humans: Humans,
        hands: Hands,
        deck: Deck3,
        pile: [Top],
        color: red,
        dir: 1,
        turn: 0,
        scores: Scores,
        verbose: Verbose,
        dry_passes: 0,
        over: none,
        turns: 0,
        round: Round,
        target: Target
    },
    opening_effect(Top, S0, S),
    log_opening(S0, S).

deal_hands([], _, Deck, [], Deck).
deal_hands([_|Players], N, Deck0, [Hand|Hands], Deck) :-
    length(Hand, N),
    append(Hand, Deck1, Deck0),
    deal_hands(Players, N, Deck1, Hands, Deck).

pick_opening(Deck0, Card, Deck) :-
    partition(is_draw4, Deck0, Draw4s, Others),
    Others = [_|_],
    random_permutation(Others, [Card|More]),
    append(More, Draw4s, Mixed),
    random_permutation(Mixed, Deck).

is_draw4(card(wild, draw4)).

opening_effect(card(wild, draw4), _, _) :-
    !,
    throw(error(domain_error(opening, draw4), opening_effect/3)).
opening_effect(card(wild, wild), S0, S) :-
    !,
    nth0(S0.turn, S0.hands, Hand),
    choose_color_for(S0, Hand, Color),
    S = S0.put(color, Color).
opening_effect(card(Color, draw2), S0, S) :-
    color(Color),
    !,
    give_cards(S0.put(color, Color), 0, 2, S1, _),
    S = S1.put(turn, 1).
opening_effect(card(Color, skip), S0, S) :-
    color(Color),
    !,
    S = S0.put(_{color: Color, turn: 1}).
opening_effect(card(Color, reverse), S0, S) :-
    color(Color),
    !,
    player_count(S0, N),
    Dealer is N - 1,
    S = S0.put(_{color: Color, dir: -1, turn: Dealer}).
opening_effect(card(Color, Rank), S0, S) :-
    color(Color),
    integer(Rank),
    !,
    S = S0.put(color, Color).

choose_color_for(S, _Hand, Color) :-
    is_human(S, S.turn),
    !,
    nth0(S.turn, S.names, Name),
    emit('~w, name the starting color.~n', [Name]),
    ask_color(Color).
choose_color_for(_, Hand, Color) :-
    choose_color(Hand, Color).

log_opening(_Before, S) :-
    S.verbose \== true,
    !.
log_opening(_Before, S) :-
    [Top|_] = S.pile,
    emit('~nRound ~d~nOpening card: ', [S.round]),
    print_card(Top),
    nl,
    (   Top = card(wild, wild)
    ->  write('Color: '), print_color(S.color), nl
    ;   true
    ),
    (   S.dir =:= -1
    ->  emit('Play order is reversed. The dealer leads.~n', [])
    ;   true
    ),
    (   Top = card(_, skip)
    ->  nth0(0, S.names, Skipped),
        player_verb(Skipped, is, are, Be),
        emit('~w ~w skipped.~n', [Skipped, Be])
    ;   true
    ),
    (   Top = card(_, draw2)
    ->  nth0(0, S.names, Drawer),
        nth0(0, S.hands, Hand),
        length(Hand, Len),
        Extra is Len - 7,
        player_verb(Drawer, draws, draw, Draw),
        player_verb(Drawer, is, are, Be),
        emit('~w ~w ~d and ~w skipped.~n', [Drawer, Draw, Extra, Be])
    ;   true
    ),
    nth0(S.turn, S.names, Lead),
    player_verb(Lead, plays, play, Verb),
    emit('~w ~w first.~n', [Lead, Verb]).

% ---------------------------------------------------------------------------
% Round loop
% ---------------------------------------------------------------------------

play_until_over(S0, S) :-
    S0.over \== none,
    !,
    S = S0.
play_until_over(S0, S) :-
    S0.turns >= 3000,
    !,
    log(S0, 'Turn limit reached. Stalemate.~n', []),
    S = S0.put(over, stalemate).
play_until_over(S0, S) :-
    no_progress_possible(S0),
    !,
    log(S0, 'No remaining card can be played. Stalemate.~n', []),
    S = S0.put(over, stalemate).
play_until_over(S0, S) :-
    take_turn(S0, S1),
    play_until_over(S1, S).

take_turn(S0, S) :-
    Turns is S0.turns + 1,
    S1 = S0.put(turns, Turns),
    (   is_human(S1, S1.turn)
    ->  human_turn(S1, S)
    ;   ai_turn(S1, S)
    ).

% ---------------------------------------------------------------------------
% Human turn
% ---------------------------------------------------------------------------

human_turn(S0, S) :-
    maybe_pass_keyboard(S0),
    show_status(S0),
    human_prompt(S0, S).

maybe_pass_keyboard(S) :-
    length(S.humans, H),
    H > 1,
    S.turns > 1,
    !,
    clear_screen,
    nth0(S.turn, S.names, Name),
    format(string(Prompt), 'Pass the keyboard to ~w, then press Enter. ', [Name]),
    prompt_line(Prompt, _).
maybe_pass_keyboard(_).

human_prompt(S0, S) :-
    (   nth0(S0.turn, S0.hands, Hand),
        length(Hand, 2)
    ->  emit('Two cards left. Call UNO like this:  4 u~n', [])
    ;   true
    ),
    prompt_line('> ', Line),
    (   parse_command(Line, Cmd)
    ->  dispatch(Cmd, S0, S)
    ;   emit('Enter a card number, d to draw, h for help, or q to quit.~n', []),
        human_prompt(S0, S)
    ).

dispatch(quit, _, _) :-
    !,
    throw(quit_game).
dispatch(help, S0, S) :-
    !,
    show_help,
    human_prompt(S0, S).
dispatch(scores, S0, S) :-
    !,
    show_scores(S0),
    emit('Playing to ~d.~n', [S0.target]),
    human_prompt(S0, S).
dispatch(draw, S0, S) :-
    !,
    human_draw(S0, S).
dispatch(play(Index, CallUno), S0, S) :-
    !,
    human_play(Index, CallUno, S0, S).

human_play(Index, CallUno, S0, S) :-
    nth0(S0.turn, S0.hands, Hand),
    sort_hand(Hand, Shown),
    (   nth1(Index, Shown, Card)
    ->  try_human_card(Card, CallUno, Hand, S0, S)
    ;   emit('There is no card ~d.~n', [Index]),
        human_prompt(S0, S)
    ).

try_human_card(Card, CallUno, Hand, S0, S) :-
    [Top|_] = S0.pile,
    (   human_can_choose(Card, Hand, Top, S0.color)
    ->  confirm_and_play(Card, CallUno, Hand, S0, S)
    ;   explain_illegal(Card, Top, S0.color),
        human_prompt(S0, S)
    ).

confirm_and_play(card(wild, draw4), CallUno, Hand, S0, S) :-
    hand_has_color(Hand, S0.color),
    !,
    (   prompt_yes('You still have the current color. Bluff anyway? [y/N] ')
    ->  ask_color_and_resolve(card(wild, draw4), CallUno, S0, S)
    ;   emit('Okay, pick another card.~n', []),
        human_prompt(S0, S)
    ).
confirm_and_play(Card, CallUno, _, S0, S) :-
    (   wild_card(Card)
    ->  ask_color_and_resolve(Card, CallUno, S0, S)
    ;   resolve_play(S0, Card, S0.color, CallUno, auto, S)
    ).

ask_color_and_resolve(Card, CallUno, S0, S) :-
    ask_color(Color),
    resolve_play(S0, Card, Color, CallUno, auto, S).

human_draw(S0, S) :-
    (   take_one(S0.deck, S0.pile, Card, Deck1, Pile1, S0.verbose)
    ->  Turn = S0.turn,
        nth0(Turn, S0.hands, Hand),
        append(Hand, [Card], Hand1),
        replace_nth0(Turn, S0.hands, Hand1, Hands),
        S1 = S0.put(_{hands: Hands, deck: Deck1, pile: Pile1}),
        write('You draw '), print_card(Card), nl, flush_output,
        offer_drawn(Card, Hand1, S0, S1, S)
    ;   emit('There are no cards left to draw.~n', []),
        pass_turn(S0, false, S)
    ).

offer_drawn(Card, Hand1, S0, S1, S) :-
    [Top|_] = S0.pile,
    (   human_can_choose(Card, Hand1, Top, S0.color)
    ->  draw_prompt(Card, Hand1, S0.color, Prompt),
        (   prompt_yes(Prompt)
        ->  play_drawn(Card, Hand1, S1, S)
        ;   emit('You keep it.~n', []),
            pass_turn(S1, true, S)
        )
    ;   emit('It does not match. Your turn ends.~n', []),
        pass_turn(S1, true, S)
    ).

draw_prompt(card(wild, draw4), Hand, Color, Prompt) :-
    hand_has_color(Hand, Color),
    !,
    Prompt = 'This Wild Draw Four is a bluff. Play it? [y/N] '.
draw_prompt(_, _, _, 'Play it? [y/N] ').

play_drawn(Card, Hand1, S1, S) :-
    length(Hand1, Len),
    (   Len =:= 2
    ->  (   prompt_yes('Call UNO? [y/N] ')
        ->  Uno = true
        ;   Uno = false
        )
    ;   Uno = false
    ),
    (   wild_card(Card)
    ->  ask_color(Color),
        resolve_play(S1, Card, Color, Uno, auto, S)
    ;   resolve_play(S1, Card, S1.color, Uno, auto, S)
    ).

% ---------------------------------------------------------------------------
% Computer player
% ---------------------------------------------------------------------------

ai_turn(S0, S) :-
    (   S0.humans == []
    ->  show_status(S0)
    ;   show_board(S0)
    ),
    nth0(S0.turn, S0.hands, Hand),
    [Top|_] = S0.pile,
    (   ai_choose(Hand, Top, S0.color, Card)
    ->  prepare_ai_play(S0, Hand, Card, S)
    ;   ai_draw(S0, S)
    ).

prepare_ai_play(S0, Hand, Card, S) :-
    (   wild_card(Card)
    ->  choose_color(Hand, Choice)
    ;   Choice = S0.color
    ),
    length(Hand, Len),
    (   Len =:= 2
    ->  Uno = true
    ;   Uno = false
    ),
    resolve_play(S0, Card, Choice, Uno, auto, S).

ai_draw(S0, S) :-
    (   take_one(S0.deck, S0.pile, Card, Deck1, Pile1, S0.verbose)
    ->  Turn = S0.turn,
        nth0(Turn, S0.hands, Hand),
        append(Hand, [Card], Hand1),
        replace_nth0(Turn, S0.hands, Hand1, Hands),
        S1 = S0.put(_{hands: Hands, deck: Deck1, pile: Pile1}),
        [Top|_] = S0.pile,
        (   can_play(Card, Hand1, Top, S0.color)
        ->  nth0(Turn, S0.names, Name),
            player_verb(Name, 'draws and plays', 'draw and play', Verb),
            log(S1, '~w ~w.~n', [Name, Verb]),
            prepare_ai_play(S1, Hand1, Card, S)
        ;   nth0(Turn, S0.names, Name),
            player_verb(Name, draws, draw, Draw),
            player_verb(Name, keeps, keep, Keep),
            log(S1, '~w ~w a card and ~w it.~n', [Name, Draw, Keep]),
            pass_turn(S1, true, S)
        )
    ;   nth0(S0.turn, S0.names, Name),
        log(S0, '~w cannot draw.~n', [Name]),
        pass_turn(S0, false, S)
    ).

ai_choose(Hand, Top, Color, Card) :-
    findall(Score-C, (
        member(C, Hand),
        can_play(C, Hand, Top, Color),
        card_score(C, Color, Score)
    ), Pairs),
    Pairs \== [],
    keysort(Pairs, Sorted),
    last(Sorted, _-Honest),
    maybe_bluff(Hand, Color, Honest, Card).

maybe_bluff(Hand, Color, Honest, card(wild, draw4)) :-
    Honest \= card(wild, draw4),
    memberchk(card(wild, draw4), Hand),
    hand_has_color(Hand, Color),
    length(Hand, Len),
    Len >= 4,
    random(Roll),
    Roll < 0.12,
    !.
maybe_bluff(_, _, Honest, Honest).

card_score(card(wild, draw4), _, 1) :- !.
card_score(card(wild, wild), _, 2) :- !.
card_score(card(Color, Rank), Color, Score) :-
    !,
    rank_dump_value(Rank, Base),
    Score is Base + 50.
card_score(card(_, Rank), _, Score) :-
    rank_dump_value(Rank, Score).

rank_dump_value(draw2, 40).
rank_dump_value(skip, 35).
rank_dump_value(reverse, 30).
rank_dump_value(N, N) :-
    integer(N).

choose_color(Hand, Color) :-
    findall(Count-C, (
        color(C),
        color_count(Hand, C, Count),
        Count > 0
    ), Pairs),
    Pairs \== [],
    !,
    keysort(Pairs, Sorted),
    last(Sorted, _-Color).
choose_color(_, red).

color_count(Hand, Color, Count) :-
    aggregate_all(count, member(card(Color, _), Hand), Count).

% ---------------------------------------------------------------------------
% Playing a card
% ---------------------------------------------------------------------------

resolve_play(S0, Card, Choice, CallUno, ChallengeMode, S) :-
    Turn = S0.turn,
    nth0(Turn, S0.hands, Hand),
    select(Card, Hand, Hand1),
    !,
    resulting_color(Card, Choice, NewColor),
    replace_nth0(Turn, S0.hands, Hand1, Hands1),
    S1 = S0.put(_{
        hands: Hands1,
        pile: [Card|S0.pile],
        color: NewColor
    }),
    (   length(Hand1, 1), CallUno == true
    ->  Shout = true
    ;   Shout = false
    ),
    log_play(S1, Card, NewColor, Shout),
    note_uno(S1, Turn, Hand1, CallUno, S2),
    apply_effect(S2, Card, Hand1, S0.color, ChallengeMode, S3),
    S4 = S3.put(dry_passes, 0),
    note_win(S4, Turn, S).

note_uno(S0, _Player, Hand1, CallUno, S) :-
    length(Hand1, 1),
    CallUno == true,
    !,
    S = S0.
note_uno(S0, Player, Hand1, CallUno, S) :-
    length(Hand1, 1),
    CallUno == false,
    !,
    nth0(Player, S0.names, Name),
    player_verb(Name, draws, draw, Draw),
    log(S0, '~w forgot to call UNO and ~w 2.~n', [Name, Draw]),
    give_cards(S0, Player, 2, S, _).
note_uno(S0, _, _, CallUno, S) :-
    (   CallUno == true
    ->  log(S0, 'UNO only counts when the play leaves one card.~n', [])
    ;   true
    ),
    S = S0.

note_win(S0, Player, S) :-
    nth0(Player, S0.hands, []),
    !,
    nth0(Player, S0.names, Name),
    player_verb(Name, 'goes out', 'go out', Verb),
    log(S0, '~w ~w.~n', [Name, Verb]),
    S = S0.put(over, Player).
note_win(S, _, S).

apply_effect(S0, card(_, skip), _, _, _, S) :-
    !,
    advance(S0, 1, S),
    log_skip(S0, S).
apply_effect(S0, card(_, reverse), _, _, _, S) :-
    !,
    apply_reverse(S0, S).
apply_effect(S0, card(_, draw2), _, _, _, S) :-
    !,
    next_player(S0, Next),
    give_cards(S0, Next, 2, S1, Drawn),
    length(Drawn, N),
    nth0(Next, S0.names, Name),
    player_verb(Name, draws, draw, Draw),
    player_verb(Name, is, are, Be),
    log(S1, '~w ~w ~d and ~w skipped.~n', [Name, Draw, N, Be]),
    advance(S1, 1, S).
apply_effect(S0, card(wild, draw4), HandAtPlay, ColorBefore, ChallengeMode, S) :-
    !,
    apply_draw4(S0, HandAtPlay, ColorBefore, ChallengeMode, S).
apply_effect(S0, _, _, _, _, S) :-
    advance(S0, 0, S).

log_skip(S0, S) :-
    next_player(S0, Skipped),
    nth0(Skipped, S0.names, Name),
    player_verb(Name, is, are, Be),
    log(S, '~w ~w skipped.~n', [Name, Be]).

apply_reverse(S0, S) :-
    player_count(S0, N),
    Dir is -S0.dir,
    (   N =:= 2
    ->  Extra = 1
    ;   Extra = 0
    ),
    S1 = S0.put(dir, Dir),
    advance(S1, Extra, S),
    (   Dir =:= 1
    ->  Way = clockwise
    ;   Way = counterclockwise
    ),
    log(S, 'Play order is now ~w.~n', [Way]).

apply_draw4(S0, HandAtPlay, ColorBefore, ChallengeMode, S) :-
    decide_challenge(ChallengeMode, S0, Decision),
    Offender = S0.turn,
    nth0(Offender, S0.names, Name),
    (   Decision == yes
    ->  log_reveal(S0, Name, HandAtPlay),
        (   hand_has_color(HandAtPlay, ColorBefore)
        ->  color_name(ColorBefore, ColorLabel),
            player_verb(Name, draws, draw, Draw),
            log(S0, 'Challenge succeeds. ~w had ~w and ~w 4.~n', [Name, ColorLabel, Draw]),
            give_cards(S0, Offender, 4, S1, _),
            advance(S1, 0, S)
        ;   next_player(S0, Next),
            nth0(Next, S0.names, Challenger),
            color_name(ColorBefore, ColorLabel),
            player_verb(Challenger, draws, draw, Draw),
            log(S0, 'Challenge fails. ~w had no ~w. ~w ~w 6.~n',
                [Name, ColorLabel, Challenger, Draw]),
            give_cards(S0, Next, 6, S1, _),
            advance(S1, 1, S)
        )
    ;   next_player(S0, Next),
        nth0(Next, S0.names, NextName),
        player_verb(NextName, draws, draw, Draw),
        player_verb(NextName, is, are, Be),
        log(S0, '~w ~w 4 and ~w skipped.~n', [NextName, Draw, Be]),
        give_cards(S0, Next, 4, S1, _),
        advance(S1, 1, S)
    ).

log_reveal(S, _Name, _Hand) :-
    S.verbose \== true,
    !.
log_reveal(_, Name, Hand) :-
    format('~w reveals: ', [Name]),
    print_cards(Hand),
    nl,
    flush_output.

decide_challenge(yes, _, yes) :- !.
decide_challenge(no, _, no) :- !.
decide_challenge(auto, S, Decision) :-
    next_player(S, Next),
    (   is_human(S, Next)
    ->  human_challenge(S, Decision)
    ;   ai_challenge(S, Decision)
    ).

human_challenge(S, Decision) :-
    nth0(S.turn, S.names, Name),
    format(string(Prompt), '~w played Wild Draw Four. Challenge? [y/N] ', [Name]),
    prompt_line(Prompt, Line),
    (   affirmed(Line)
    ->  Decision = yes
    ;   Decision = no
    ).

ai_challenge(S, Decision) :-
    nth0(S.turn, S.hands, Hand),
    length(Hand, Len),
    random(Roll),
    (   Len =< 2
    ->  Threshold = 0.45
    ;   Len =< 4
    ->  Threshold = 0.20
    ;   Threshold = 0.08
    ),
    (   Roll < Threshold
    ->  Decision = yes
    ;   Decision = no
    ).

log_play(S, _Card, _Choice, _Shout) :-
    S.verbose \== true,
    !.
log_play(S, Card, Choice, Shout) :-
    nth0(S.turn, S.names, Name),
    player_verb(Name, plays, play, Verb),
    format('~w ~w ', [Name, Verb]),
    print_card(Card),
    (   wild_card(Card)
    ->  write(', names '),
        print_color(Choice)
    ;   true
    ),
    (   Shout == true
    ->  write(' — UNO!')
    ;   true
    ),
    nl,
    flush_output.

% ---------------------------------------------------------------------------
% Deck, drawing, turn order
% ---------------------------------------------------------------------------

full_deck(Deck) :-
    findall(card(C, 0), color(C), Zeros),
    findall(card(C, N), (color(C), between(1, 9, N), member(_, [1, 2])), Numbers),
    findall(card(C, A), (
        color(C),
        member(A, [skip, reverse, draw2]),
        member(_, [1, 2])
    ), Actions),
    findall(card(wild, wild), member(_, [1, 2, 3, 4]), Wilds),
    findall(card(wild, draw4), member(_, [1, 2, 3, 4]), Draw4s),
    append([Zeros, Numbers, Actions, Wilds, Draw4s], Deck).

color(red).
color(yellow).
color(green).
color(blue).

wild_card(card(wild, _)).

give_cards(S0, Player, N, S, Drawn) :-
    nth0(Player, S0.hands, Hand),
    draw_n(N, Hand, S0.deck, S0.pile, Hand2, Deck2, Pile2, Drawn, S0.verbose),
    replace_nth0(Player, S0.hands, Hand2, Hands),
    S = S0.put(_{hands: Hands, deck: Deck2, pile: Pile2}),
    length(Drawn, Got),
    (   Got < N
    ->  log(S, 'Only ~d of ~d cards could be drawn.~n', [Got, N])
    ;   true
    ).

draw_n(0, Hand, Deck, Pile, Hand, Deck, Pile, [], _) :- !.
draw_n(N, Hand, Deck, Pile, HandOut, DeckOut, PileOut, [Card|Drawn], Verbose) :-
    N > 0,
    take_one(Deck, Pile, Card, Deck1, Pile1, Verbose),
    !,
    append(Hand, [Card], Hand1),
    N1 is N - 1,
    draw_n(N1, Hand1, Deck1, Pile1, HandOut, DeckOut, PileOut, Drawn, Verbose).
draw_n(N, Hand, Deck, Pile, Hand, Deck, Pile, [], _) :-
    N > 0.

take_one(Deck, Pile, Card, Deck2, Pile2, Verbose) :-
    (   Deck == [],
        Verbose == true,
        Pile = [_, _|_]
    ->  emit('The deck is empty. Reshuffling the discard pile.~n', [])
    ;   true
    ),
    !,
    take_one_silent(Deck, Pile, Card, Deck2, Pile2).

take_one_silent([Card|Deck], Pile, Card, Deck, Pile) :- !.
take_one_silent([], [Top|Rest], Card, Deck, [Top]) :-
    Rest \= [],
    random_permutation(Rest, [Card|Deck]).

pass_turn(S0, Drew, S) :-
    player_count(S0, N),
    next_index(S0.turn, S0.dir, N, 0, Next),
    (   Drew == true
    ->  Dry = 0
    ;   Dry is S0.dry_passes + 1
    ),
    S1 = S0.put(_{turn: Next, dry_passes: Dry}),
    (   Dry >= N
    ->  log(S1, 'Nobody can draw. Stalemate.~n', []),
        S = S1.put(over, stalemate)
    ;   S = S1
    ).

advance(S0, Extra, S) :-
    player_count(S0, N),
    next_index(S0.turn, S0.dir, N, Extra, Next),
    S = S0.put(turn, Next).

next_player(S, Next) :-
    player_count(S, N),
    next_index(S.turn, S.dir, N, 0, Next).

next_index(Turn, Dir, Players, Extra, Next) :-
    Delta is Dir * (1 + Extra),
    Next is (Turn + Delta) mod Players.

player_count(S, N) :-
    length(S.names, N).

% ---------------------------------------------------------------------------
% Rules
% ---------------------------------------------------------------------------

matches(card(wild, _), _, _) :- !.
matches(card(Color, _), _, Color) :-
    color(Color),
    !.
matches(card(Color, Rank), card(_, Rank), _) :-
    color(Color),
    matchable_rank(Rank).

matchable_rank(Rank) :-
    integer(Rank),
    !.
matchable_rank(skip).
matchable_rank(reverse).
matchable_rank(draw2).

can_play(card(wild, draw4), Hand, _, Color) :-
    !,
    \+ hand_has_color(Hand, Color).
can_play(Card, _, Top, Color) :-
    matches(Card, Top, Color).

human_can_choose(card(wild, draw4), _, _, _) :- !.
human_can_choose(Card, Hand, Top, Color) :-
    can_play(Card, Hand, Top, Color).

hand_has_color(Hand, Color) :-
    color(Color),
    memberchk(card(Color, _), Hand).

resulting_color(card(wild, _), Choice, Choice) :-
    color(Choice),
    !.
resulting_color(card(Color, Rank), _, Color) :-
    color(Color),
    Rank \= wild,
    Rank \= draw4.

card_points(card(_, N), N) :-
    integer(N),
    !.
card_points(card(_, skip), 20) :- !.
card_points(card(_, reverse), 20) :- !.
card_points(card(_, draw2), 20) :- !.
card_points(card(wild, _), 50).

hand_points(Hand, Points) :-
    maplist(card_points, Hand, Ps),
    sum_list(Ps, Points).

no_progress_possible(S) :-
    S.pile = [Top|_],
    S.pile = [_|Buried],
    append(S.hands, Held),
    append(Held, S.deck, Mixed),
    append(Mixed, Buried, Rest),
    \+ (member(Card, Rest), matches(Card, Top, S.color)).

all_cards(S, Cards) :-
    append(S.hands, Held),
    append(Held, S.deck, Mixed),
    append(Mixed, S.pile, Cards).

total_cards(S, N) :-
    all_cards(S, Cards),
    length(Cards, N).

% ---------------------------------------------------------------------------
% Commands and prompts
% ---------------------------------------------------------------------------

parse_command(Line, Cmd) :-
    split_string(Line, " ", " ", Parts),
    Parts \== [""],
    maplist(token_atom, Parts, Tokens),
    tokens_command(Tokens, Cmd).

token_atom(Str, Atom) :-
    string_lower(Str, Lower),
    atom_string(Atom, Lower).

tokens_command([q], quit).
tokens_command([quit], quit).
tokens_command([h], help).
tokens_command([help], help).
tokens_command(['?'], help).
tokens_command([s], scores).
tokens_command([score], scores).
tokens_command([scores], scores).
tokens_command([d], draw).
tokens_command([draw], draw).
tokens_command([A], play(N, false)) :-
    atom_number(A, N),
    N > 0.
tokens_command([A, u], play(N, true)) :-
    atom_number(A, N),
    N > 0.
tokens_command([A, uno], play(N, true)) :-
    atom_number(A, N),
    N > 0.
tokens_command([u, A], play(N, true)) :-
    atom_number(A, N),
    N > 0.
tokens_command([A], play(N, true)) :-
    atom_concat(Num, u, A),
    Num \== '',
    atom_number(Num, N),
    N > 0.

ask_number(Prompt, Default, Min, Max, Value) :-
    format('~w [~d]: ', [Prompt, Default]),
    flush_output,
    read_line_to_string(user_input, Raw),
    (   Raw == end_of_file
    ->  throw(quit_game)
    ;   normalize_space(string(Line), Raw),
        parse_bounded(Line, Default, Min, Max, Value)
    ->  true
    ;   emit('Enter a whole number from ~d to ~d.~n', [Min, Max]),
        ask_number(Prompt, Default, Min, Max, Value)
    ).

parse_bounded("", Default, Min, Max, Default) :-
    Default >= Min,
    Default =< Max,
    !.
parse_bounded(Line, _, Min, Max, Value) :-
    number_string(Value, Line),
    integer(Value),
    Value >= Min,
    Value =< Max.

ask_line(Prompt, Default, Value) :-
    format('~w [~w]: ', [Prompt, Default]),
    flush_output,
    read_line_to_string(user_input, Raw),
    (   Raw == end_of_file
    ->  throw(quit_game)
    ;   normalize_space(string(Line), Raw),
        (   Line == ""
        ->  Value = Default
        ;   Value = Line
        )
    ).

prompt_line(Prompt, Line) :-
    format('~w', [Prompt]),
    flush_output,
    read_line_to_string(user_input, Raw),
    (   Raw == end_of_file
    ->  throw(quit_game)
    ;   normalize_space(string(Line), Raw)
    ).

prompt_yes(Prompt) :-
    prompt_line(Prompt, Line),
    affirmed(Line).

affirmed(Line) :-
    string_lower(Line, Lower),
    (Lower == "y" ; Lower == "yes").

ask_color(Color) :-
    prompt_line('Color (r, y, g, b): ', Line),
    (   parse_color(Line, Color)
    ->  true
    ;   string_lower(Line, Lower),
        Lower == "q"
    ->  throw(quit_game)
    ;   emit('Enter r, y, g, or b.~n', []),
        ask_color(Color)
    ).

parse_color(Line, Color) :-
    string_lower(Line, Lower),
    color_token(Lower, Color).

color_token("r", red).
color_token("red", red).
color_token("y", yellow).
color_token("yellow", yellow).
color_token("g", green).
color_token("green", green).
color_token("b", blue).
color_token("blue", blue).

gather_human_names(Count, Names) :-
    gather_human_names(1, Count, Names).

gather_human_names(I, Count, []) :-
    I > Count,
    !.
gather_human_names(I, Count, [Name|Rest]) :-
    default_human_name(I, Count, Default),
    format(string(Prompt), 'Name for player ~d', [I]),
    ask_line(Prompt, Default, Name),
    I2 is I + 1,
    gather_human_names(I2, Count, Rest).

default_human_name(1, 1, "You") :- !.
default_human_name(I, _, Name) :-
    format(string(Name), 'Player ~d', [I]).

human_indexes(0, []) :- !.
human_indexes(N, Indexes) :-
    Last is N - 1,
    numlist(0, Last, Indexes).

ai_roster(["Ada", "Kurt", "Grace", "Alan", "Barbara", "Edsger", "Don", "Niklaus", "Jean", "Betty"]).

take_n(0, _, []) :- !.
take_n(N, [H|T], [H|R]) :-
    N > 0,
    N1 is N - 1,
    take_n(N1, T, R).

% ---------------------------------------------------------------------------
% Display
% ---------------------------------------------------------------------------

intro :-
    banner,
    emit('Enter a card number on your turn, or d to draw.~n', []),
    emit('Call UNO when you play down to one card:  4 u~n', []),
    emit('Type h for the rules.~n~n', []).

banner :-
    nl,
    paint([bold], '~w~n', ['=============================']),
    paint([bold, fg(red)], '  U ', []),
    paint([bold, fg(yellow)], 'N ', []),
    paint([bold, fg(green)], 'O', []),
    nl,
    paint([bold], '~w~n', ['=============================']),
    nl.

show_help :-
    emit('~nMatch the color or the rank, or play a Wild.~n', []),
    emit('  Skip            next player loses a turn~n', []),
    emit('  Reverse         flip the order (with 2 players, you play again)~n', []),
    emit('  Draw Two        next player draws 2 and loses a turn~n', []),
    emit('  Wild            choose the next color~n', []),
    emit('  Wild Draw Four  choose the next color; next player draws 4~n', []),
    emit('                  and loses a turn. Legal only with no card of~n', []),
    emit('                  the current color. You may bluff.~n', []),
    emit('Challenge a Wild Draw Four. If they had the color, they draw 4.~n', []),
    emit('If they did not, you draw 6.~n', []),
    emit('Draw with d when you want a card. You may play that card at once.~n', []),
    emit('Actions and Wilds score 20 and 50. Numbers score face value.~n', []),
    emit('Commands: card number, 4 u, d, h, s, q~n~n', []).

show_status(S) :-
    S.verbose \== true,
    !.
show_status(S) :-
    show_board(S),
    (   is_human(S, S.turn)
    ->  show_hand(S)
    ;   true
    ).

show_board(S) :-
    S.verbose \== true,
    !.
show_board(S) :-
    [Top|_] = S.pile,
    nth0(S.turn, S.names, Name),
    nl,
    write('Discard: '),
    print_card(Top),
    (   wild_card(Top)
    ->  write('   calling '),
        print_color(S.color)
    ;   true
    ),
    (   S.dir =:= 1
    ->  Way = clockwise
    ;   Way = counterclockwise
    ),
    nl,
    write('Color: '),
    print_color(S.color),
    format('    Order: ~w    Round ~d    To ~d~n', [Way, S.round, S.target]),
    show_turn(Name),
    show_counts(S),
    flush_output.

show_counts(S) :-
    forall(nth0(I, S.names, Name), (
        nth0(I, S.hands, Hand),
        nth0(I, S.scores, Score),
        length(Hand, Len),
        (   I =:= S.turn
        ->  Marker = ' <<'
        ;   Marker = ''
        ),
        cards_label(Len, Word),
        format('  ~w: ~d ~w, ~d pts~w~n', [Name, Len, Word, Score, Marker])
    )).

show_hand(S) :-
    nth0(S.turn, S.hands, Hand),
    sort_hand(Hand, Shown),
    [Top|_] = S.pile,
    emit('Your hand:~n', []),
    forall(nth1(I, Shown, Card),
           show_hand_card(I, Card, Hand, Top, S.color)),
    emit('  * playable     ? Wild Draw Four bluff~n', []).

show_hand_card(I, Card, Hand, Top, Color) :-
    marker(Card, Hand, Top, Color, Mark),
    format('~t~d~3|  ', [I]),
    print_card(Card),
    format('~w~n', [Mark]).

marker(card(wild, draw4), Hand, _, Color, '  ?') :-
    hand_has_color(Hand, Color),
    !.
marker(Card, Hand, Top, Color, '  *') :-
    human_can_choose(Card, Hand, Top, Color),
    !.
marker(_, _, _, _, '').

sort_hand(Hand, Sorted) :-
    findall(k(C, R, I)-Card, (
        nth0(I, Hand, Card),
        Card = card(Color, Rank),
        color_key(Color, C),
        rank_key(Rank, R)
    ), Pairs),
    keysort(Pairs, Ordered),
    pairs_values(Ordered, Sorted).

color_key(red, 1).
color_key(yellow, 2).
color_key(green, 3).
color_key(blue, 4).
color_key(wild, 5).

rank_key(Rank, Rank) :-
    integer(Rank),
    !.
rank_key(skip, 10).
rank_key(reverse, 11).
rank_key(draw2, 12).
rank_key(wild, 13).
rank_key(draw4, 14).

reveal_all(S) :-
    S.verbose \== true,
    !.
reveal_all(S) :-
    emit('~nCards left:~n', []),
    forall(nth0(I, S.names, Name), (
        nth0(I, S.hands, Hand),
        hand_points(Hand, Points),
        format('  ~w (~d): ', [Name, Points]),
        print_cards(Hand),
        nl
    )),
    flush_output.

show_scores_if(S) :-
    (   S.verbose == true
    ->  show_scores(S)
    ;   true
    ),
    !.

show_scores(S) :-
    emit('Scoreboard:~n', []),
    forall(nth0(I, S.names, Name), (
        nth0(I, S.scores, Score),
        format('  ~w: ~d~n', [Name, Score])
    )),
    flush_output.

print_cards([]) :-
    !,
    write('(none)').
print_cards([Card]) :-
    !,
    print_card(Card).
print_cards([Card|Cards]) :-
    print_card(Card),
    write(', '),
    print_cards(Cards).

print_card(card(wild, wild)) :-
    !,
    paint([bold, fg(magenta)], 'Wild', []).
print_card(card(wild, draw4)) :-
    !,
    paint([bold, fg(magenta)], 'Wild Draw Four', []).
print_card(card(Color, Rank)) :-
    color_attr(Color, Attr),
    color_name(Color, Name),
    rank_label(Rank, Label),
    paint(Attr, '~w ~w', [Name, Label]).

print_color(Color) :-
    color_attr(Color, Attr),
    color_name(Color, Name),
    paint(Attr, '~w', [Name]).

color_name(red, 'Red').
color_name(yellow, 'Yellow').
color_name(green, 'Green').
color_name(blue, 'Blue').

second_person(Name) :-
    string(Name),
    string_lower(Name, Lower),
    Lower == "you".

player_verb(Name, _Third, Second, Second) :-
    second_person(Name),
    !.
player_verb(_, Third, _, Third).

show_turn(Name) :-
    second_person(Name),
    !,
    emit('--- Your turn ---~n', []).
show_turn(Name) :-
    format('--- ~w''s turn ---~n', [Name]).

cards_label(1, card) :- !.
cards_label(_, cards).

color_attr(red, [bold, fg(red)]).
color_attr(yellow, [bold, fg(yellow)]).
color_attr(green, [bold, fg(green)]).
color_attr(blue, [bold, fg(blue)]).

rank_label(Rank, Label) :-
    integer(Rank),
    !,
    format(string(Label), '~d', [Rank]).
rank_label(skip, 'Skip').
rank_label(reverse, 'Reverse').
rank_label(draw2, 'Draw Two').

paint(Attrs, Format, Args) :-
    use_color,
    !,
    ansi_format(Attrs, Format, Args).
paint(_, Format, Args) :-
    format(Format, Args).

use_color :-
    stream_property(user_output, tty(true)),
    \+ current_prolog_flag(color_term, false).

clear_screen :-
    stream_property(user_output, tty(true)),
    !,
    format('~c[2J~c[H', [27, 27]).
clear_screen.

emit(Format, Args) :-
    format(Format, Args),
    flush_output.

log(S, Format, Args) :-
    (   S.verbose == true
    ->  emit(Format, Args)
    ;   true
    ),
    !.

explain_illegal(Card, Top, Color) :-
    write('You cannot play '),
    print_card(Card),
    write(' on '),
    print_card(Top),
    write(' while the color is '),
    print_color(Color),
    emit('.~n', []).

is_human(S, Index) :-
    memberchk(Index, S.humans).

replace_nth0(Index, List, Value, New) :-
    nth0(Index, List, _, Rest),
    nth0(Index, New, Value, Rest).

% ---------------------------------------------------------------------------
% Tests
% ---------------------------------------------------------------------------

run_checks :-
    check('deck has 108 legal cards', test_deck),
    check('opening card is never Wild Draw Four', test_opening_not_draw4),
    check('deal conserves the deck', test_deal),
    check('matching rules', test_matches),
    check('Wild Draw Four restriction', test_draw4_rule),
    check('card points', test_points),
    check('turn index', test_next_index),
    check('commands', test_commands),
    check('stuck position', test_stuck),
    check('effects, UNO, and challenges', test_effects),
    check('eight computer rounds', test_ai_games).

check(Name, Goal) :-
    (   call(Goal)
    ->  true
    ;   format(user_error, 'FAIL: ~w~n', [Name]),
        fail
    ).

test_deck :-
    full_deck(D),
    length(D, 108),
    count_card(D, card(wild, wild), 4),
    count_card(D, card(wild, draw4), 4),
    forall(color(C), (
        count_card(D, card(C, 0), 1),
        forall(between(1, 9, N), count_card(D, card(C, N), 2)),
        forall(member(A, [skip, reverse, draw2]), count_card(D, card(C, A), 2))
    )).

count_card(Deck, Card, N) :-
    include(=(Card), Deck, Hits),
    length(Hits, N).

test_opening_not_draw4 :-
    full_deck(D),
    random_permutation(D, Shuffled),
    pick_opening(Shuffled, Card, Rest),
    Card \= card(wild, draw4),
    msort(Shuffled, A),
    msort([Card|Rest], B),
    A == B.

test_deal :-
    Names = ["Ada", "Kurt", "Grace", "Alan"],
    Scores = [0, 0, 0, 0],
    deal_new_round(Names, [], false, Scores, 1, 500, S),
    total_cards(S, 108),
    maplist(at_least_seven, S.hands),
    S.pile = [_|_],
    color(S.color),
    member(S.dir, [1, -1]),
    S.over == none.

at_least_seven(Hand) :-
    length(Hand, N),
    N >= 7.

test_matches :-
    matches(card(red, 5), card(blue, 5), blue),
    matches(card(red, 5), card(red, 7), red),
    \+ matches(card(red, 5), card(blue, 7), blue),
    matches(card(wild, wild), card(blue, 7), blue),
    matches(card(green, skip), card(red, skip), red),
    \+ matches(card(green, skip), card(red, reverse), red),
    matches(card(blue, draw2), card(red, draw2), red).

test_draw4_rule :-
    can_play(card(wild, draw4), [card(wild, draw4)], card(red, 2), red),
    \+ can_play(card(wild, draw4), [card(wild, draw4), card(red, 1)], card(blue, 2), red),
    can_play(card(wild, wild), [card(wild, wild), card(red, 1)], card(blue, 2), red).

test_points :-
    hand_points([card(wild, wild), card(red, 5), card(blue, skip)], 75).

test_next_index :-
    next_index(0, 1, 4, 0, 1),
    next_index(0, 1, 4, 1, 2),
    next_index(0, -1, 4, 0, 3),
    next_index(0, -1, 2, 1, 0),
    next_index(1, 1, 2, 1, 1),
    next_index(3, 1, 4, 0, 0).

test_commands :-
    parse_command("4", play(4, false)),
    parse_command("4 u", play(4, true)),
    parse_command("4u", play(4, true)),
    parse_command("u 3", play(3, true)),
    parse_command("d", draw),
    parse_command("Q", quit),
    parse_command("h", help),
    \+ parse_command("", _).

test_stuck :-
    skeleton([[card(blue, 1)]], [], [card(red, 5)], red, 1, 0, S1),
    no_progress_possible(S1),
    skeleton([[card(red, 1)]], [], [card(red, 5)], red, 1, 0, S2),
    \+ no_progress_possible(S2),
    skeleton([[card(blue, 1)]], [card(wild, wild)], [card(red, 5)], red, 1, 0, S3),
    \+ no_progress_possible(S3).

test_effects :-
    test_plain_win,
    test_uno_penalty,
    test_draw2_two_players,
    test_reverse_two_players,
    test_reverse_three_players,
    test_bluff_caught,
    test_draw4_unchallenged,
    test_failed_challenge,
    test_opening_skip,
    test_opening_reverse.

test_plain_win :-
    skeleton(
        [[card(red, 5)], [card(blue, 1)]],
        [],
        [card(red, 9)],
        red, 1, 0, S0),
    resolve_play(S0, card(red, 5), red, false, no, S),
    S.over =:= 0,
    nth0(0, S.hands, []),
    same_card_count(S0, S).

test_uno_penalty :-
    skeleton(
        [[card(red, 5), card(blue, 2)], [card(green, 9)]],
        [card(yellow, 1), card(yellow, 3)],
        [card(red, 7)],
        red, 1, 0, S0),
    resolve_play(S0, card(red, 5), red, false, no, S),
    nth0(0, S.hands, Hand),
    length(Hand, 3),
    S.over == none,
    S.turn =:= 1,
    same_card_count(S0, S).

test_draw2_two_players :-
    skeleton(
        [[card(red, draw2), card(blue, 1), card(blue, 2)], [card(green, 4)]],
        [card(yellow, 8), card(yellow, 9)],
        [card(red, 3)],
        red, 1, 0, S0),
    resolve_play(S0, card(red, draw2), red, false, no, S),
    nth0(1, S.hands, Opp),
    length(Opp, 3),
    S.turn =:= 0,
    S.over == none,
    same_card_count(S0, S).

test_reverse_two_players :-
    skeleton(
        [[card(red, reverse), card(blue, 1), card(blue, 2)], [card(green, 3)]],
        [],
        [card(red, 4)],
        red, 1, 0, S0),
    resolve_play(S0, card(red, reverse), red, false, no, S),
    S.dir =:= -1,
    S.turn =:= 0,
    same_card_count(S0, S).

test_reverse_three_players :-
    skeleton(
        [[card(blue, 1)],
         [card(red, reverse), card(blue, 2), card(blue, 3)],
         [card(green, 9)]],
        [],
        [card(red, 1)],
        red, 1, 1, S0),
    resolve_play(S0, card(red, reverse), red, false, no, S),
    S.dir =:= -1,
    S.turn =:= 0,
    same_card_count(S0, S).

test_bluff_caught :-
    skeleton(
        [[card(wild, draw4), card(red, 9)], [card(blue, 1)]],
        [card(yellow, 1), card(yellow, 2), card(yellow, 3), card(yellow, 4)],
        [card(red, 3)],
        red, 1, 0, S0),
    resolve_play(S0, card(wild, draw4), blue, true, yes, S),
    nth0(0, S.hands, Hand0),
    length(Hand0, 5),
    nth0(1, S.hands, [card(blue, 1)]),
    S.turn =:= 1,
    S.over == none,
    S.color == blue,
    same_card_count(S0, S).

test_draw4_unchallenged :-
    skeleton(
        [[card(wild, draw4)], [card(blue, 1)]],
        [card(yellow, 1), card(yellow, 2), card(yellow, 3), card(yellow, 4)],
        [card(red, 3)],
        red, 1, 0, S0),
    resolve_play(S0, card(wild, draw4), green, false, no, S),
    nth0(0, S.hands, []),
    nth0(1, S.hands, Opp),
    length(Opp, 5),
    S.over =:= 0,
    S.color == green,
    same_card_count(S0, S).

test_failed_challenge :-
    skeleton(
        [[card(wild, draw4)], [card(blue, 1)]],
        [card(yellow, 1), card(yellow, 2), card(yellow, 3), card(yellow, 4)],
        [card(red, 3)],
        red, 1, 0, S0),
    resolve_play(S0, card(wild, draw4), green, false, yes, S),
    nth0(0, S.hands, []),
    nth0(1, S.hands, Opp),
    length(Opp, 6),
    S.deck == [],
    S.pile == [card(wild, draw4)],
    S.over =:= 0,
    same_card_count(S0, S).

test_opening_skip :-
    skeleton([[], []], [], [card(red, skip)], red, 1, 0, S0),
    opening_effect(card(red, skip), S0, S),
    S.turn =:= 1,
    S.color == red.

test_opening_reverse :-
    skeleton([[], [], [], []], [], [card(blue, reverse)], red, 1, 0, S0),
    opening_effect(card(blue, reverse), S0, S),
    S.turn =:= 3,
    S.dir =:= -1,
    S.color == blue.

test_ai_games :-
    forall(between(1, 8, _), test_one_ai_game).

test_one_ai_game :-
    Names = ["Ada", "Kurt", "Grace", "Alan"],
    Scores = [0, 0, 0, 0],
    deal_new_round(Names, [], false, Scores, 1, 500, S0),
    total_cards(S0, 108),
    play_until_over(S0, S1),
    total_cards(S1, 108),
    (   integer(S1.over)
    ->  nth0(S1.over, S1.hands, [])
    ;   S1.over == stalemate
    ).

same_card_count(A, B) :-
    total_cards(A, N),
    total_cards(B, N).

skeleton(Hands, Deck, Pile, Color, Dir, Turn, S) :-
    length(Hands, N),
    player_names(N, Names),
    length(Scores, N),
    maplist(=(0), Scores),
    S = state{
        names: Names,
        humans: [],
        hands: Hands,
        deck: Deck,
        pile: Pile,
        color: Color,
        dir: Dir,
        turn: Turn,
        scores: Scores,
        verbose: false,
        dry_passes: 0,
        over: none,
        turns: 0,
        round: 1,
        target: 500
    }.

player_names(N, Names) :-
    numlist(1, N, Indexes),
    maplist(pname, Indexes, Names).

pname(I, Name) :-
    format(string(Name), 'P~d', [I]).
