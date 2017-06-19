# FFBE AutoScript
The script of AnkuLua Pro 2 for game FFBE (Final Fantasy: Brave Exvius).

I make this auto script for free my hand and eyes.  I feel i took too much time on it, but I still want to play it.  
There are many half-monthly events in this game.  It's always doing the boring things to get strong equipments.  And the funny things always need strong equipment.
To help me go through the boring, I wrote these code.  And I also had a lot of fun in coding this.  If this game still attract me, I will
like to keep update this.

The many pictures for searching locations are with Chinese letters.  If you are other language user, you should change your image for yourself.

This script has following features:
* Quest/Event/Trust farming
  * Auto battle
  * Use abilities.
  * Use items.
  * Can use Gem to full stamina
  * WatchDog for timeout.  And do error handling.
  * Not to add new friend.
  * Can choose friend company or not.
  * Can cancel daily issue dialog.
* Run exploration
  * Auto move, But you need make sure player not go to next room.
  * Auto Battle
  * Use abilities
  * Use items.
  * Vibrate notification when reaching specified battle number or timeout.

If you need new feature or meet problems, go to discuss page or mail me.


# DBS file
DBS is the abbreviation of Designed Battle Script. It's a script to descript how
units do in a battle. You can set up your units use abilities, use items, do
normal attack or defence in every single round. You can also launch a unit's
actions in a specified time.

The script can be edit by other text editor. And it's easy to understand and
easy to write in a mobile. The script support comment, which help you remember
the script's meanings.

## The DBS Syntax
  In order to correctly detect the round begin and end, Please let all unit has
  actions.

### Space and Newline
DBS will ignore all white space including the line change in its script, for 
example, 0x20, '\t', '\r', and '\n'.  However the comment will end with new line.

You can insert space in all commands.  For example, a compact script,

    su1a1l1lrlae

You can insert white space and comment to let it more human readable:

    s  ' round 1
      u 1 a 1  ' prepare normal attack, unit 1
      l1 lr l a   ' Go, unit 1 and some units repeat the actions last round, and the rest auto attack.
    e

### Basic instructions
* *s*

  Round start.  The round will end with *e*.  Each start will be given a round
  number. The FFBE AutoScript will choose a round in your DBS to act. You should
  script the rounds in a natural number order.

* *e*

  Round end.  The round should has a start with *s*.  After *e*, you can start a
  new round with *s*.

* *u#*

  Units. Choose a unit by a index number # which is in the same order in FFBE game.
  *u1* is the unit 1, *u6* is the friend unit. The # index count from up to
  down first, and repeat from left to right.

* *a#*

  Actions. Actions are Attack, Ability, Item, and Defence which are represented
  by number # from 1 to 4. *a1* means attack, *a2* means ability, etc.

* *i#*

  Item or Ability index.  The index is count from left to right first, and repeat
  next line.  Thus the index 1 means the LP. and index 2 usually means Esper's 
  LP.
  
  *i6* will use the ability or item index 6. *i7* will drag the list down one
  line and choose the index 7. *i13* will drag the list down one page and one
  line and choose the index 13.
  
  If you use a dual cast, you can use *i* many times.
  
  If you want to use a ability or item on an units, you need append a target
  *t#* right after the *i#*.

* *t#*

  An allie target, unit *#*, to cast. if target to all, choose any unit as a
  represent.

* *l#*

  Launch unit index *#*.  Let the actions happen.  for example, ``*l5l2l4l3l1*``.
  
* *lr*

  Launch units by "Repeat" button.

* *la*

  Launch units by "Auto" button.

* *w#*

  Wait for *#* millisecond.

<!--
* *d#*
  Wait since first unit was launched for *#* millisecond.
!-->

### Comment
* ' line comment
* " line comment
* " inline comment "
* ' inline comment '
* " nested 'comment'"

### Example
#### basic

    s ' the 1st round battle (not the showing rounds, like (3/4 round), in the game)
      u1a2i5 ' unit 1 use index 5 ability
      u2a3i1 ' unit 2 use index 1 item
      u3a2i14i5i6 ' unit 3 use index 14 ability, which is dual cast.  And select magics at indext 5 and at index 6
      l1 w500 l2 w10 l3 ' launch unit 1, wait 500ms, launch unit 2, wait 10ms, launch unit 3
      la ' launch all other players by "Auto" button of game UI.
    e ' end 1st round
    s ' the 2nd round
      lr ' repeat last round by "Repeat" button of game UI
    e ' end 2nd round
    lr  ' if round is greater than 2nd round, do a global command, "Repeat"

#### other demo
Please check out the [demo1.dbs](https://github.com/quakerntj/ffbe_autoscript/blob/master/demo1.dbs) or [quest2.dbs](https://github.com/quakerntj/ffbe_autoscript/blob/master/quest2.dbs).
