import subprocess

commands = [
    ["git", "pull"],
    ["git", "add", "."],
    ["git", "commit", "-m", "Automated commit"],
    ["git", "push"]
]

for command in commands:
    print(f"\nRunning: {' '.join(command)}")
    result = subprocess.run(command)

    if result.returncode != 0:
        print(f"Command failed: {' '.join(command)}")
        break

print("\nDone.")