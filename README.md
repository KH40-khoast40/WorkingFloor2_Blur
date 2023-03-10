# WorkingFloor2_Blur
An edited version of WorkingFloor2 by 針金P, with new function to make the reflection blurry

<img src="https://i.imgur.com/mLs179t.png" alt="alt text">
<img src="https://i.imgur.com/B79afGg.png" alt="alt text">

Original version can be found here: https://hariganep.seesaa.net/

# Usage
Load **WorkingFloor2_Blur.pmx** *(it has the same role as the .x file in the original version, but now with sliders for configurations, and a bone to move/rotate the surface)*

# Notices
- Make **WorkingFloor2_Blur.pmx** be **last** at the "model display order" table, or else it won't look right when the surface is semi-transparent

<img src="https://i.imgur.com/L57jHvI.png" alt="alt text">

- In case the effect causes low frame rate *(bc you run serveral surfaces at once, or your computer is simply a potato)*, you can change the resolution of the reflection by changing the **#define Resolution** value in **WorkingFloor2_Blur.fx**. Reasonably low resolution should still look decent when being blurred, and it increases the frame rate

<img src="https://i.imgur.com/SjuZNzH.png" alt="alt text">

- If the model doesn't have reflection, chance that it doesn't have *WF_Object.fxsub* applied in the WorkingFloorRT tab of MME

# Rules
- Feel free to edit, and distribute the edit
- Don't re-distribute the effect without changing anything. Instead, link to this page
- Credit 針金P and KH40 when you use the effect, and when you distribute edits of the effect

# Credits
- Original effect by [針金P](https://twitter.com/hariganep)
- Edited by [KH40](https://twitter.com/khoast40)
