from dateutil import parser
from dateutil.parser import ParserError

with open("./old-minutes.md", "r") as file_in:
    lines = file_in.read()

# Fix strings that are not properly formatted
lines = lines.replace("# 19\\. Nov 2024", "# 19 Nov 2024")
lines = lines.replace("# 22\\. Oct 2024", "# 22 Oct 2024")
lines = lines.replace("# 3\\. July 2024", "# 3 July 2024")
lines = lines.replace(
    "# 14 September 2023 Attendees:", "# 14 September 2023\nAttendees:"
)
lines = lines.replace("# 16 August 2023 Attendees:", "# 16 August 2023\nAttendees:")
lines = lines.replace("# 2 August 2023 Attendees:", "# 2 August 2023\nAttendees:")
lines = lines.replace("# 19 July 2023 Attendees:", "# 19 July 2023\nAttendees:")
lines = lines.replace("# 5 July 2023 Attendees:", "# 5 July 2023\nAttendees:")
lines = lines.replace("# ~~14th~~ October 2020", "# 14 October 2020")
lines = lines.replace("2nd September 2020", "# 2 September 2020")
lines = lines.replace("22th July 2020", "# 22 July 2020")
lines = lines.replace("8th July 2020", "# 8 July 2020")

# Fix strings that are not properly formatted
lines = lines.replace(
    "# 8 November 2023 Attendees: \\- Tom (@tomberek)   \\- Dan (@djacu) \\- Thilo (@thilobillerbeck) \\- Ida (@idabzo) Agenda: \\- website: reviewing the changes and discussing next steps \\- newsletter: the draft has been completed, however, it has not yet been released \\- Tom is asking if we want to refresh [https://nixos.org/blog/](https://nixos.org/blog/) a little bit with new content, like blogs (he would like to contribute) \\- mentioned: https://github.com/nix-rfc-canonical-domain/rfcs/blob/canonical-domain/rfcs/1000-canonical-domain.md 25 October 2023",
    "# 8 November 2023\nAttendees:\n- Tom (@tomberek)\n- Dan (@djacu)\n- Thilo (@thilobillerbeck)\n- Ida (@idabzo)\nAgenda:\n- website: reviewing the changes and discussing next steps\n- newsletter: the draft has been completed, however, it has not yet been released\n- Tom is asking if we want to refresh [https://nixos.org/blog/](https://nixos.org/blog/) a little bit with new content, like blogs (he would like to contribute)\n- mentioned: https://github.com/nix-rfc-canonical-domain/rfcs/blob/canonical-domain/rfcs/1000-canonical-domain.md\n# 25 October 2023",
)

old_minutes = [line.strip() for line in lines.splitlines()]

# Filter out empty lines
old_minutes = [line for line in old_minutes if line.strip()]
# Remove everything from TEMPLATE: line and after
old_minutes = old_minutes[: old_minutes.index("TEMPLATE:")]
# Force a basic set of headings
old_minutes = ["# Attendees:" if line == "Attendees:" else line for line in old_minutes]
old_minutes = ["# Agenda:" if line == "Agenda:" else line for line in old_minutes]
old_minutes = ["# Minutes:" if line == "Minutes:" else line for line in old_minutes]


minutes = dict()
next_meeting_date = None
next_meeting_contents = []
for line in old_minutes:
    try:
        if next_meeting_date is not None:
            minutes[next_meeting_date] = next_meeting_contents

        next_meeting_date = str(parser.parse(line[2:], fuzzy=False).date())
        next_meeting_contents = []
    except ParserError:
        next_meeting_contents.append(line)

for meeting_date, meeting_notes in minutes.items():
    with open(f"../{meeting_date}.md", "w") as out_file:
        out_file.write("\n".join(meeting_notes))
