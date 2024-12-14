# The Survivor

## Summary

**A paragraph-length pitch for your game.**

## Project Resources

[Web-playable version of your game.](https://itch.io/)  
[Trailor](https://youtube.com)  
[Press Kit](https://dopresskit.com/)  
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1qwWCpMwKJGOLQ-rRJt8G8zisCa2XHFhv6zSWars0eWM/edit?usp=sharing)

## Gameplay Explanation

**In this section, explain how the game should be played. Treat this as a manual within a game. Explaining the button mappings and the most optimal gameplay strategy is encouraged.**

**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure

If your project contains code that: 1) your team did not write, and 2) does not fit cleanly into a role, please document it in this section. Please include the author of the code, where to find the code, and note which scripts, folders, or other files that comprise the external contribution. Additionally, include the license for the external code that permits you to use it. You do not need to include the license for code provided by the instruction team.

If you used tutorials or other intellectual guidance to create aspects of your project, include reference to that information as well.

# Main Roles

Your goal is to relate the work of your role and sub-role in terms of the content of the course. Please look at the role sections below for specific instructions for each role.

Below is a template for you to highlight items of your work. These provide the evidence needed for your work to be evaluated. Try to have at least four such descriptions. They will be assessed on the quality of the underlying system and how they are linked to course content.

_Short Description_ - Long description of your work item that includes how it is relevant to topics discussed in class. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
_Procedural Terrain_ - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

## Producer

**Describe the steps you took in your role as producer. Typical items include group scheduling mechanisms, links to meeting notes, descriptions of team logistics problems with their resolution, project organization tools (e.g., timelines, dependency/task tracking, Gantt charts, etc.), and repository management methodology.**

## User Interface and Input

**Describe your user interface and how it relates to gameplay. This can be done via the template.**
**Describe the default input configuration.**

**Add an entry for each platform or input style your project supports.**

## Movement/Physics
Name: Hamza Ahmed
Email: harhmed@ucdavis.edu
Github: hamzahmed1234

We used a lot of the default physics settings like gravity to implement the jump control. Jump is the up arrow control and plays a sound effect when pushed. When the player is not on the floor we also simulate falling behaviors. Horizontal movement is handles by the left and right arrow keys. In the idle state velocity is set to 0. We also have our slide movement which has a separate hitbox corresponding to movement. The slide control will make the hitbox much smaller and the hitbox will go back to normal when the slide is complete. The sword physics also works as the sword can damage the demon within its hitbox.

The boss movement is directly dependent on the players location as seen in the boss.gd class. If the boss is to class to the player than it will go into the idle state but continue attacking. There is also an attack timer to make sure that the boss does not attack constantly. The boss alternates between walking attacking and stopping. Both the boss and player can damage each other with there weapons.
and under narrative desgin
I designed the overall story of the game and cutscenes. Designing each cutscene took a bit of time but overall I am very happy with the way they look. I think one of the hardest parts of implementing the cutscenes was making sure that they start at the right times. Getting all the cutscenes to work at the right time took extensive debugging. For the sake of simplicity, I added cutscenes in three core areas. These areas being the beginning of the game, when the boss is first encountered, and once the boss is defeated. I did this by making an ENUM of the three cutscene types I used a timer node to delay between each scene. Sample cutscene:

## Animation and Visuals

**List your assets, including their sources and licenses.**

**Describe how your work intersects with game feel, graphic design, and world-building. Include your visual style guide if one exists.**

## Game Logic

**Document the game states and game data you managed and the design patterns you used to complete your task.**

# Sub-Roles

## Audio

**List your assets, including their sources and licenses.**

**Describe the implementation of your audio system.**

**Document the sound style.**

## Gameplay Testing

**Add a link to the full results of your gameplay tests.**

**Summarize the key findings from your gameplay tests.**

## Narrative Design
Name: Hamza Ahmed
Email: harhmed@ucdavis.edu
Github: hamzahmed1234

I designed the overall story of the game and cutscenes. Designing each cutscene took a bit of time but overall I am very happy with the way they look. I think one of the hardest parts of implementing the cutscenes was making sure that they start at the right times. Getting all the cutscenes to work at the right time took extensive debugging. For the sake of simplicity, I added cutscenes in three core areas. These areas being the beginning of the game, when the boss is first encountered, and once the boss is defeated. I did this by making an ENUM of the three cutscene types I used a timer node to delay between each scene. Sample cutscene:

## Press Kit and Trailer

**Include links to your presskit materials and trailer.**

**Describe how you showcased your work. How did you choose what to show in the trailer? Why did you choose your screenshots?**

## Game Feel and Polish

**Document what you added to and how you tweaked your game to improve its game feel.**
