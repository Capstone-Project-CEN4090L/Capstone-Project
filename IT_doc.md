1. Programming Languages

Our project uses GDScript, which is heavily inspired by Python. GDScript is used to write all our scripts for our player character, enemy behavior, etc. GDScript is built into the game engine we chose to develop our project with.

---

2. Platforms, APIs, Databases, and other technologies used

We are developing this project entirely within the Godot game engine. There are no network connectivity features in our game as it is exclusively a single player experience, so we have no need for APIs or databases. All artwork for the game either uses stock placeholders found online or was drawn by our artist using simple drawing programs like MS Paint.

---

3. Execution-based Functional Testing

We have not begun testing for FR 1 yet as we haven't yet moved on to the level design phase of this project and only just recently began to finalize the upgrade path for the player. FR 2 is tested by running the project's main scene in Godot after any changes, tweaks, or additions are made to the player character's moveset. In the main scene we have a designated testing area in which we can freely move the player character around, jump between platforms, and interact with enemies to test any changes. Perfecting the character movement has been the biggest focus of this first increment.

---

4. Execution-based Non-Functional Testing

As mentioned in the previous section, we use Godot's built in "run scene" feature to test things like movement feel and controls frequently as changes are made. For maintainability and organization, each team member works on their own branch on GitHub, and we have gotten into the habit of making new scenes when building new elements or features (e.g. developing a new enemy) to test individually in Godot. This reduces chances of merge conflicts occurring and will allow us to easily incorporate the most important changes into the main scene later.

---

5. Non-execution-based Testing

As we continue to finalize the various features of our project and significant team member contributions are pushed to the main branch of our repository in future increments, most non-execution-based testing will be performed via pull requests requiring multiple reviewers on GitHub. In addition to this, we communicate frequently on Discord, using the VC feature to demo new features to each other and mutually determine whether the associated code is safe, optimal, and readable.
