"""Add durable audit events for administrator account changes.

Revision ID: 20260820_02
Revises: 20260820_01
Create Date: 2026-08-20
"""

import sqlalchemy as sa

from alembic import op

revision = "20260820_02"
down_revision = "20260820_01"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "admin_audit_events",
        sa.Column("id", sa.String(), nullable=False),
        sa.Column("actor_employee_id", sa.String(), nullable=False),
        sa.Column("target_employee_id", sa.String(), nullable=False),
        sa.Column("action", sa.String(), nullable=False),
        sa.Column("details", sa.String(), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_admin_audit_events_actor_employee_id",
        "admin_audit_events",
        ["actor_employee_id"],
    )
    op.create_index(
        "ix_admin_audit_events_target_employee_id",
        "admin_audit_events",
        ["target_employee_id"],
    )
    op.create_index(
        "ix_admin_audit_events_created_at",
        "admin_audit_events",
        ["created_at"],
    )


def downgrade() -> None:
    op.drop_index("ix_admin_audit_events_created_at", table_name="admin_audit_events")
    op.drop_index(
        "ix_admin_audit_events_target_employee_id",
        table_name="admin_audit_events",
    )
    op.drop_index(
        "ix_admin_audit_events_actor_employee_id",
        table_name="admin_audit_events",
    )
    op.drop_table("admin_audit_events")
