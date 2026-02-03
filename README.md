# MailHelper (WoW Vanilla 1.12)

A lightweight and intuitive recipient manager for the standard World of Warcraft mail interface. No more typing alt names or friends' nicknames manually!

## ✨ Features
*   📦 **Contact List:** Dedicated side panel attached to the Mail Frame.
*   🖱️ **Drag-and-Drop:** Real-time list sorting (Shift + Click to pick up and drop elements).
*   🛡️ **Smart Input:** Automatic whitespace trimming and empty-string protection.
*   🔄 **TurtleMail Compatible:** Full support for TurtleMail’s auto-capitalization logic.
*   💾 **Persistent Storage:** Your list is automatically saved across sessions via SavedVariables.

## 🕹️ Controls
- **LMB:** Insert name into the "To:" field.
- **Shift + LMB:** Pick up / Place an item to reorder the list.
- **Shift + RMB:** Remove name from the list.
- **Enter (in input field):** Quickly add a new name to the list.
- **Main Helper Button:** Show / Hide Mail Helper panel.

## 🛠️ Installation
1. Download the repository.
2. Extract the folder into your `Interface\AddOns\` directory.
3. **Important:** Ensure the folder is named exactly `MailHelper` (remove any `-master` suffixes).
4. Restart the game or reload the UI.

## 🔧 Technical Overview
*   **Optimization:** Uses a centralized `OnUpdate` controller for smooth dragging with minimal CPU impact.
*   **UI Integration:** Designed to fit the Vanilla aesthetic; compatible with `pfUI` skinning.
*   **Safe Interaction:** Direct API calls to ensure name injection works even with heavy UI overhauls.

---
*Developed for the Vanilla 1.12 community.*


## Info
Addon for creating a sender list for mail

Working for default interface and also supports work with the [TurtleMail](https://github.com/sica42/TurtleMail) addon.

## Main cmd
Enter in chat `/mailhelper`

<img width="604" height="219" alt="image" src="https://github.com/user-attachments/assets/bd2e5f66-ef65-4a85-8b77-07e80cd0df07" />

## Interface

<img width="874" height="787" alt="image" src="https://github.com/user-attachments/assets/54650c65-d5a0-4074-9fee-16b726b1fc31" />
<img width="609" height="812" alt="image" src="https://github.com/user-attachments/assets/eaa363b6-7568-4e8b-894e-d40742e7459a" />


### Integration with pfUI

<img width="825" height="717" alt="image" src="https://github.com/user-attachments/assets/3ebb81b9-3023-48d6-8a67-3777b28bd26d" />
<img width="687" height="853" alt="image" src="https://github.com/user-attachments/assets/28201a80-c00d-4228-b8bc-31a4f87991e4" />


