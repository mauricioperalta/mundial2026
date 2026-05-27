<script lang="ts">
	import { api, type LeagueSummary } from '$lib/api';
	import { goto } from '$app/navigation';
	import { Users } from '@lucide/svelte';

	let leagues = $state<LeagueSummary[]>([]);
	let loaded = $state(false);
	let newName = $state('');
	let joinCode = $state('');
	let error = $state('');
	let busy = $state(false);

	async function load() {
		try {
			leagues = (await api.myLeagues()).leagues;
		} catch {
			/* ignorar */
		} finally {
			loaded = true;
		}
	}
	$effect(() => {
		load();
	});

	async function create(e: Event) {
		e.preventDefault();
		error = '';
		busy = true;
		try {
			const r = await api.createLeague(newName);
			newName = '';
			goto(`/leagues/${r.id}`);
		} catch {
			error = 'No se pudo crear la liga.';
		} finally {
			busy = false;
		}
	}

	async function join(e: Event) {
		e.preventDefault();
		error = '';
		busy = true;
		try {
			const r = await api.joinLeague(joinCode);
			joinCode = '';
			goto(`/leagues/${r.id}`);
		} catch {
			error = 'Código de invitación inválido.';
		} finally {
			busy = false;
		}
	}
</script>

<p class="kicker">Competí con tus amigos</p>
<h1>Ligas</h1>

<section class="card">
	<h3>Tus Ligas</h3>
	{#if !loaded}
		<p class="muted">Cargando ligas…</p>
	{:else if leagues.length === 0}
		<p class="muted">Ninguna todavía — creá una o unite con un código.</p>
	{:else}
		{#each leagues as l (l.id)}
			<a class="lrow" href={`/leagues/${l.id}`}>
				<span>{l.name}</span>
				{#if l.role === 'owner'}<span class="pill">creador</span>{/if}
				<span class="spacer"></span>
				<span class="cnt"><Users size={15} /> {l.members}</span>
			</a>
		{/each}
	{/if}
</section>

<section class="card">
	<h3>Crear una liga</h3>
	<form onsubmit={create}>
		<div class="field">
			<input class="input" placeholder="Nombre de la liga" bind:value={newName} required />
		</div>
		<button class="btn" disabled={busy || !newName.trim()}>Crear</button>
	</form>
</section>

<section class="card">
	<h3>Unirse a una liga</h3>
	<form onsubmit={join}>
		<div class="field">
			<input
				class="input code"
				placeholder="CÓDIGO DE INVITACIÓN"
				bind:value={joinCode}
				required
			/>
		</div>
		<button class="btn secondary" disabled={busy || !joinCode.trim()}>Unirse</button>
	</form>
</section>

{#if error}<p class="error">{error}</p>{/if}

<style>
	/* Mantenemos todo el bloque CSS intacto */
	h1 {
		margin: 1rem 0 0.2rem;
	}
	.muted {
		margin: 0 0 0.25rem;
		font-size: 0.9rem;
	}
	.kicker {
		margin: 0;
		font-size: 0.75rem;
		font-weight: 700;
		text-transform: uppercase;
		letter-spacing: 0.08em;
		color: var(--muted);
	}
	h3 {
		margin: 0 0 0.5rem;
		font-family: var(--font-display);
		text-transform: uppercase;
		font-size: 1rem;
	}
	.card {
		background: var(--surface);
		border: 1px solid var(--border);
		border-radius: var(--radius);
		padding: 1.25rem 1.5rem;
		margin-top: 1rem;
		display: flex;
		flex-direction: column;
		box-shadow: var(--shadow-sm);
	}
	.lrow {
		display: flex;
		align-items: center;
		gap: 0.65rem;
		padding: 0.65rem 0.85rem;
		background: var(--surface-2);
		border: 1px solid var(--border);
		border-radius: var(--radius-sm);
		text-decoration: none;
		color: inherit;
		font-weight: 600;
		font-size: 0.95rem;
		margin-top: 0.4rem;
	}
	.lrow:hover {
		border-color: var(--accent);
	}
	.pill {
		font-size: 0.65rem;
		font-weight: 800;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		background: rgba(var(--accent-rgb), 0.1);
		color: var(--accent);
		padding: 2px 6px;
		border-radius: 4px;
	}
	.spacer {
		flex: 1;
	}
	.cnt {
		display: inline-flex;
		align-items: center;
		gap: 4px;
		font-size: 0.8rem;
		color: var(--muted);
	}
	.field {
		margin: 0.4rem 0 0.75rem;
	}
	.input {
		background: var(--surface-2);
		border: 1px solid var(--border);
		border-radius: var(--radius-sm);
		padding: 0.55rem 0.75rem;
		color: var(--text);
		font-size: 0.95rem;
		width: 100%;
		transition: border-color 0.15s ease;
	}
	.input:focus {
		outline: none;
		border-color: var(--accent);
	}
	.input.code {
		font-family: monospace;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}
	.error {
		background: var(--danger-subtle, #fde8e8);
		color: var(--danger, #e02424);
		border: 1px solid var(--danger-border, #f8b4b4);
		padding: 0.55rem 0.75rem;
		border-radius: var(--radius-sm);
		font-size: 0.85rem;
		font-weight: 500;
		margin-top: 1rem;
	}
</style>
