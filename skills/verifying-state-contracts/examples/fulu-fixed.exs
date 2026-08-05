%{
  name: "Fulu automation authority through death recovery",
  axes: %{
    life: [:alive, :dead],
    control: [:active, :manual_pause, :connection_pause, :lease_pause],
    authority: [:valid, :lost],
    operation: [:idle, :returning, :hunting, :recovering]
  },
  initial: %{life: :alive, control: :active, authority: :valid, operation: :returning},
  writers: %{
    life: [:combat, :recovery],
    control: [:player, :session, :lease],
    authority: [:lease],
    operation: [:automation, :player, :session, :lease, :combat, :recovery]
  },
  questions: [],
  check_deadlocks: true,
  terminal_when: [%{authority: :lost}],
  invariants: [
    %{
      name: "lost authority owns the pause",
      check: {:implies, {:eq, :authority, :lost}, {:eq, :control, :lease_pause}}
    },
    %{
      name: "hunting requires active valid control",
      check:
        {:implies, {:eq, :operation, :hunting},
         {:and, [{:eq, :control, :active}, {:eq, :authority, :valid}, {:eq, :life, :alive}]}}
    }
  ],
  transition_rules: [
    %{
      name: "death preserves control ownership",
      trigger: :death,
      preserve: [:control, :authority]
    }
  ],
  transitions: [
    %{
      name: :begin_hunting,
      trigger: :arrive_at_lock_map,
      owner: :automation,
      when: %{life: :alive, control: :active, authority: :valid, operation: :returning},
      set: %{operation: :hunting},
      preserve: [:life, :control, :authority]
    },
    %{
      name: :finish_return,
      trigger: :route_planned,
      owner: :automation,
      when: %{life: :alive, control: :active, authority: :valid, operation: :idle},
      set: %{operation: :returning},
      preserve: [:life, :control, :authority]
    },
    %{
      name: :manual_pause,
      trigger: :pause_command,
      owner: :player,
      when: %{life: :alive, control: :active, authority: :valid},
      set: %{control: :manual_pause, operation: :idle},
      preserve: [:life, :authority]
    },
    %{
      name: :manual_resume,
      trigger: :resume_command,
      owner: :player,
      when: %{life: :alive, control: :manual_pause, authority: :valid},
      set: %{control: :active, operation: :returning},
      preserve: [:life, :authority]
    },
    %{
      name: :connection_lost,
      trigger: :connection_lost,
      owner: :session,
      when: %{life: :alive, control: :active, authority: :valid},
      set: %{control: :connection_pause, operation: :idle},
      preserve: [:life, :authority]
    },
    %{
      name: :connection_restored_alive,
      trigger: :connection_restored,
      owner: :session,
      when: %{life: :alive, control: :connection_pause, authority: :valid},
      set: %{control: :active, operation: :returning},
      preserve: [:life, :authority]
    },
    %{
      name: :connection_restored_dead,
      trigger: :connection_restored,
      owner: :session,
      when: %{life: :dead, control: :connection_pause, authority: :valid},
      set: %{control: :active},
      preserve: [:life, :authority, :operation]
    },
    %{
      name: :manual_resume_dead,
      trigger: :resume_command,
      owner: :player,
      when: %{life: :dead, control: :manual_pause, authority: :valid},
      set: %{control: :active},
      preserve: [:life, :authority, :operation]
    },
    %{
      name: :death,
      trigger: :death,
      owner: :combat,
      when: %{life: :alive},
      set: %{life: :dead, operation: :recovering},
      preserve: [:control, :authority]
    },
    %{
      name: :respawn,
      trigger: :respawn_due,
      owner: :recovery,
      when: %{life: :dead},
      set: %{life: :alive, operation: :idle},
      preserve: [:control, :authority]
    },
    %{
      name: :lease_lost,
      trigger: :lease_lost,
      owner: :lease,
      when: %{authority: :valid},
      set: %{authority: :lost, control: :lease_pause, operation: :idle},
      preserve: [:life]
    }
  ]
}
