# Study Planner App

## Overview
The Study Planner App helps users efficiently schedule study sessions by allowing them to add subjects, set difficulty levels, and allocate time slots. The app uses OpenAI to generate an optimized study schedule based on user-defined time slots and subject difficulties.

## Features
- Add subjects with difficulty levels (Easy, Medium, Hard)
- Define and save custom time slots for study sessions
- Automatically generate study schedules using OpenAI
- View and manage scheduled study sessions
- Persistent storage using `SharedPreferences`

## Installation
### Prerequisites
- Flutter SDK installed
- OpenAI API key
- Dart installed

### Steps to Run
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/study-planner.git
   cd study-planner
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure OpenAI API Key:
   - Create a `.env` file in the project root
   - Add your OpenAI API key:
     ```
     OPENAI_API_KEY=your_api_key_here
     ```
4. Run the application:
   ```bash
   flutter run
   ```

## Usage
1. Navigate to **Manage Time Slots** to define study periods.
2. Go to **Add Subjects** to add subjects with difficulty levels.
3. Click **Generate Schedule** to let AI optimize study sessions.
4. View the schedule on the **Home Page**.

## API Integration
- Uses OpenAI API for intelligent schedule generation.
- API requests are made via `http` package.
- Error handling ensures smooth functionality.

## License
This project is licensed under the GNU General Public License v3.0. See `LICENSE.md` for details.

## Contributing
Contributions are welcome! Please open an issue or pull request on GitHub.

## Contact
For any issues or suggestions, reach out via GitHub issues.

