$startDate = [datetime]"2026-04-27"
$endDate = [datetime]"2026-05-31"

while ($startDate -le $endDate) {
    $dateStr = $startDate.ToString("yyyy-MM-ddTHH:mm:ss")
    $env:GIT_AUTHOR_DATE = $dateStr
    $env:GIT_COMMITTER_DATE = $dateStr
    git commit --allow-empty -m "Backfill contribution: $($startDate.ToString('yyyy-MM-dd'))"
    $startDate = $startDate.AddDays(1)
}
