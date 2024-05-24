#!/bin/bash

TASKS_FILE="tasks.txt"

validate_date() {
    date -d "$1" "+%Y-%m-%d" >/dev/null 2>&1
    return $?
}

validate_time() {
    [[ "$1" =~ ^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$ ]]
}

initialize_tasks_file() {
    [[ ! -f $TASKS_FILE ]] && touch $TASKS_FILE
}

append_task() {
    echo "$1|$2|$3|$4|$5|$6" >> $TASKS_FILE
}

list_tasks_by_status() {
    local status=$1
    grep "|$status" $TASKS_FILE
}

display_tasks_for_today() {
    current_date=$(date "+%Y-%m-%d")
    echo "Tasks for $current_date:"

    completed=$(list_tasks_by_status "yes")
    uncompleted=$(list_tasks_by_status "no")

    echo "Completed Tasks:"
    echo "$completed" | while IFS= read -r task; do
        echo "$task"
    done

    echo "Uncompleted Tasks:"
    echo "$uncompleted" | while IFS= read -r task; do
        echo "$task"
    done
}

create_new_task() {
    read -p "Enter title (required): " title
    [[ -z $title ]] && { echo "Title is required" >&2; return; }

    read -p "Enter due date (YY/MM/DD, required): " due_date
    validate_date "$due_date" || { echo "Invalid date format. Use YY/MM/DD" >&2; return; }

    read -p "Enter due time (HH:MM, required): " due_time
    validate_time "$due_time" || { echo "Invalid time format. Use HH:MM" >&2; return; }

    due_datetime="$due_date $due_time"

    read -p "Enter description (optional): " description
    read -p "Enter location (optional): " location
    read -p "Is the task completed? (yes/no, optional): " completed

    task_id=$(($(wc -l < $TASKS_FILE) + 1))
    append_task "$task_id" "$title" "$description" "$location" "$due_datetime" "$completed"
    echo "Task $task_id created successfully."
}

modify_task() {
    read -p "Enter task title to update: " search_title

    task=$(grep "|$search_title|" $TASKS_FILE)
    [[ -z $task ]] && { echo "No task found with title containing '$search_title'" >&2; return; }

    read -p "Enter new title (leave empty to keep current): " title
    read -p "Enter new due date (YY/MM/DD, leave empty to keep current): " due_date
    [[ -n $due_date ]] && ! validate_date "$due_date" && { echo "Invalid date format. Use YY/MM/DD" >&2; return; }
    read -p "Enter new due time (HH:MM, leave empty to keep current): " due_time
    [[ -n $due_time ]] && ! validate_time "$due_time" && { echo "Invalid time format. Use HH:MM" >&2; return; }
    read -p "Enter new description (leave empty to keep current): " description
    read -p "Enter new location (leave empty to keep current): " location
    read -p "Is the task completed? (yes/no, leave empty to keep current): " completed

    IFS="|" read -r old_task_id old_title old_description old_location old_due_datetime old_completed <<< "$task"

    updated_title="${title:-$old_title}"
    updated_description="${description:-$old_description}"
    updated_location="${location:-$old_location}"
    updated_due_date="${due_date:-${old_due_datetime% *}}"
    updated_due_time="${due_time:-${old_due_datetime#* }}"
    updated_due_datetime="$updated_due_date $updated_due_time"
    updated_completed="${completed:-$old_completed}"

    awk -v search_title="$search_title" -v updated_title="$updated_title" -v updated_description="$updated_description" \
        -v updated_location="$updated_location" -v updated_due_datetime="$updated_due_datetime" \
        -v updated_completed="$updated_completed" \
        -F'|' 'tolower($2) ~ tolower(search_title) {OFS="|"; $2=updated_title; $3=updated_description; $4=updated_location; $5=updated_due_datetime; $6=updated_completed} 1' $TASKS_FILE > tmp && mv tmp $TASKS_FILE

    echo "Task with title containing '$search_title' updated successfully."
}

remove_task() {
    read -p "Enter task title to delete: " search_title

    task=$(grep "|$search_title|" $TASKS_FILE)
    [[ -z $task ]] && { echo "No task found with title containing '$search_title'" >&2; return; }

    sed -i "/|${search_title}|/d" $TASKS_FILE
    echo "Task with title containing '$search_title' deleted successfully."
}

show_task_details() {
    read -p "Enter task title to view: " search_title

    task=$(grep "|$search_title|" $TASKS_FILE)
    [[ -z $task ]] && { echo "No task found with title containing '$search_title'" >&2; return; }

    IFS="|" read -r task_id title description location due_datetime completed <<< "$task"
    formatted_due_date=$(date -d "$due_datetime" "+%y/%m/%d")
    formatted_due_time=$(date -d "$due_datetime" "+%H:%M")

    echo "Title: $title"
    echo "Description: $description"
    echo "Location: $location"
    echo "Due Date: $formatted_due_date"
    echo "Due Time: $formatted_due_time"
    
echo "Completed: $completed"
}
list_tasks_for_day() {
    local selected_day=$1
    echo "Tasks for $selected_day:"

    completed=$(grep "|$selected_day.*yes" $TASKS_FILE)
    uncompleted=$(grep "|$selected_day.*no" $TASKS_FILE)

    echo "Completed Tasks:"
    echo "$completed" | while IFS= read -r task; do
        echo "$task"
    done

    echo "Uncompleted Tasks:"
    echo "$uncompleted" | while IFS= read -r task; do
        echo "$task"
    done
}
search_task_by_title() {
    local search_title=$1
    task=$(grep "|$search_title|" $TASKS_FILE)
    [[ -z $task ]] && { echo "No task found with title containing '$search_title'" >&2; return; }
    echo "$task"
}
case $1 in
    create)
        initialize_tasks_file
        create_new_task
        ;;
    update)
        initialize_tasks_file
        modify_task
        ;;
    delete)
        initialize_tasks_file
        remove_task
        ;;
    show)
        initialize_tasks_file
        show_task_details
        ;;
    list)
        initialize_tasks_file
        display_tasks_for_today
        ;;
    search)
        initialize_tasks_file
        read -p "Enter the title of the task to search: " search_title
        search_task_by_title "$search_title"
        ;;
    *)
        initialize_tasks_file
        display_tasks_for_today
        ;;
esac
