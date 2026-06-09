"""Cheap sanity tests that exercise the code location without touching Postgres.

The expensive integration paths (real materializations, schedule ticks) belong
in the Dagster UI / dagit-driven test harness; here we keep things fast so
`pytest -q` is part of a normal edit loop.
"""

from platform.definitions import defs


def test_definitions_compile():
    repo = defs.get_repository_def()
    assert repo is not None


def test_jobs_are_registered():
    repo = defs.get_repository_def()
    job_names = {job.name for job in repo.get_all_jobs()}
    assert "refresh_raw" in job_names
    assert "build_marts" in job_names


def test_schedules_are_wired():
    repo = defs.get_repository_def()
    schedule_names = {sched.name for sched in repo.schedule_defs}
    assert "hourly_raw_refresh" in schedule_names
    assert "nightly_marts_build" in schedule_names


def test_asset_groups_present():
    repo = defs.get_repository_def()
    groups = {asset.group_names_by_key for asset in repo.assets_defs_by_key.values()}  # type: ignore[attr-defined]
    flat = {name for group_map in groups for name in group_map.values()}
    assert {"raw", "curated"}.issubset(flat)
