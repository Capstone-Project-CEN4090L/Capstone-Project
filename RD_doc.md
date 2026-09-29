1. Overview

This project will be a short "Metroidvania"-style video game in which
players can control a character from a 2D side scrolling perspective to explore an
interconnected world, with a focus on smooth movement and tight, responsive
controls. By exploring the map and/or defeating bosses scattered around the world,
players can collect various items and upgrades to help them traverse the world, unlock new
pathways, and aid in combat with enemies/bosses. The game will be designed to be
beatable in one sitting.
____

2. Functional Requirements

    1. One interconnected map that is short enough for the player to beat in one-sitting. As the player makes progress, they should be able to collect items that make the player stronger over the course of the playthrough. With enough/all items, they would be able to defeat a final boss. This requirement is high priority. 

    2. Relatively simple but unrestrictive move set, allowing for a fun and memorable experience for the player. This includes a jump, double jump, attack, air attack, and dash. Items that are collected throughout the game will make these properties stronger/faster, as well as give some new abilities (subject to change). This requirement is high priority. 

____

3. Non-functional Requirements

   1. Control Responsiveness: Player movement should feel satisfying and natural relative to Godot's 2D physics engine, with immediate and predictable responses to player input. Movement should remain consistent throughout the map. Features such as coyote time should be implemented where appropriate so that difficult platforming feels challenging rather than frustrating.
  
   2. Level Readability: The structure of each area should clearly communicate its intended traversal path. When entering a new room, the player should be able to identify where they can go without excessive trial and error. Difficulty should come primarily from mastering movement and platforming rather than determining the intended path.

   3. Reliability: The player should be able to complete the game from beginning to end without encountering bugs that prevent progression. No area required for progression should become permanently inaccessible because of player mistakes, death, respawning, or unintended interactions with game mechanics.

   4. Maintainability: Game systems should be organized so that team members can modify individual components, such as enemies, player abilities, upgrades, and level sections, without requiring major changes to unrelated systems. Scripts, scenes, and assets should follow consistent naming and organizational conventions to reduce development complexity and merge conflicts.
   
____

5. Use Case Diagram

____

7. Class Diagram and/or Sequence Diagrams

____

9. Operating Environment

____

10. Assumptions and Dependencies
