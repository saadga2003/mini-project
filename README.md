# mini-project

The script is organized into several functions, each responsible for a specific task:
- `create_new_task`: Adds a new task with various details.
- `modify_task`: Modifies an existing task.
- `remove_task`: Deletes a task based on its title.
- `show_task_details`: Displays detailed information about a task.
- `display_tasks_for_today`: Lists tasks for the current day.
- `search_task_by_title`: Finds tasks based on their title.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

- Task data is stored in a text file named `tasks.txt`. Each task is represented as a line in the file, with fields separated by the "|" character. The fields include:
1. Task ID
2. Title
3. Description
4. Location
5. Due Date
6. Due Time
7. Completion Status

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

To run the program, follow these steps:
1. Ensure you have Bash installed on your system.
2. Clone the repository to your local machine: `git clone <(https://github.com/saadga2003/mini-project.git)>`
3. Navigate to the project directory: `cd mini-project`
4. Make the script executable: `chmod +x todo.sh`
5. Run the script with one of the following actions:
   - `./todo.sh create`: Create a new task.
   - `./todo.sh update`: Update an existing task.
   - `./todo.sh delete`: Remove a task.
   - `./todo.sh show`: Show detailed information about a task.
   - `./todo.sh list`: List tasks for today.
   - `./todo.sh search`: Search for a task by title.
