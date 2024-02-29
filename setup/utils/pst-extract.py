import sys

try:
    from aspose.email import MsgSaveOptions, MailMessageSaveType
    from aspose.email.storage.pst import PersonalStorage
except ImportError:
    try:
        sys.path.append("C:/venv/aspose/lib/site-packages")
        from aspose.email import MsgSaveOptions, MailMessageSaveType
        from aspose.email.storage.pst import PersonalStorage
    except ImportError:
        print("Please install aspose libraries for Python")
        sys.exit()

import string
from pathlib import Path

if len(sys.argv) != 2 or sys.argv[1] == "--help" or sys.argv[1] == "-h":
    print("Usage: pst-extract.py <PST_FILE>")
    sys.exit()

PST_FILE = sys.argv[1]

if not Path(PST_FILE).is_file():
    print("No such PST file:", PST_FILE)
    sys.exit()

pst = PersonalStorage.from_file(PST_FILE)
attachment_nr = 1
msg_nr = 1
valid_chars = "-_.() %s%s" % (string.ascii_letters, string.digits)


# Handle a messages in folder and call the function recursively for every subfolder
def handle_folder(current):
    print("Working on folder:", current.retrieve_full_path())
    for sub_folder in current.enumerate_folders():
        handle_folder(sub_folder)
    for message in current.get_contents():
        mapi = pst.extract_message(message)
        save_attachments(mapi)
        save_msg(mapi)


# Save msg file for current message
def save_msg(msg):
    global msg_nr
    global valid_chars
    if msg.subject:
        file_path = str(msg_nr) + "-" + msg.subject + ".msg"
        subject = msg.subject
    else:
        file_path = str(msg_nr) + "-NO-SUBJECT.msg"
        subject = "NO-SUBJECT"
    file_path = "".join(c for c in file_path if c in valid_chars)
    print("Saving msg file for message %s as: %s" % (subject, file_path))
    msg_save_options = MsgSaveOptions(
        MailMessageSaveType.outlook_message_format_unicode
    )
    msg_save_options.preserve_original_dates = True
    msg.save(file_path, msg_save_options)
    msg_nr = msg_nr + 1


# Save every attachment for the current message
def save_attachments(msg):
    global attachment_nr
    global valid_chars
    if msg.subject:
        subject = msg.subject
    else:
        subject = "NO-SUBJECT"
    print("Working on attachments in message with subject:", subject)
    for attachment in msg.attachments:
        if attachment.display_name:
            file_path = str(attachment_nr) + "-" + attachment.display_name
            file_name = attachment.display_name
        elif attachment.long_file_name:
            file_path = str(attachment_nr) + "-" + attachment.long_file_name
            file_name = attachment.long_file_name
        elif attachment.file_name:
            file_path = str(attachment_nr) + "-" + attachment.file_name
            file_name = attachment.file_name
        else:
            file_path = str(attachment_nr) + "-unknown.dat"
            file_name = "unknown.dat"
    file_path = "".join(c for c in file_path if c in valid_chars)
    print("Saving original %s attachment as %s" % (file_name, file_path))
    attachment_nr = attachment_nr + 1
    with open(file_path, "wb") as file:
        file.write(attachment.binary_data)


# Start with enumerating folders in the root folder
for folder in pst.root_folder.enumerate_folders():
    handle_folder(folder)
