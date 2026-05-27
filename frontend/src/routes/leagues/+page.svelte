<script lang="ts">
	import { api, type LeagueSummary } from '$lib/api';
	import { Users } from '@lucide/svelte';

	let leagues = $state<LeagueSummary[]>([]);
	let loaded = $state(false);

	async function load() {
		try {
			leagues = (await api.myLeagues()).leagues;
		} catch {
			/* ignore */
		} finally {
			loaded = true;
		}
	}
	$effect(() => {
		load();
	});
</script>

<p class="kicker">Competí con tus amigos</p>
<h1>Ligas</h1>
<p class="muted">Competencias privadas — tus pronósticos contra los de tus amigos.</p>

<section class="card">
	<h3>Tus ligas</h3>
	{#if !loaded}
		<p class="muted">Cargando…</p>
	{:else if leagues.length === 0}
		<p class="muted">Todavía no estás en ninguna liga.</p>
	{:else}
		{#each leagues as l (l.id)}
			<a class="lrow" href={`/leagues/${l.id}`}>
				<span>{l.name}</span>
				{#if l.role === 'owner'}<span class="pill">admin</span>{/if}
				<span class="spacer"></span>
				<span class="cnt"><Users size={15} /> {l.members}</span>
			</a>
		{/each}
	{/if}
</section>

<style>
	h1 {
		margin: 1rem 0 0.2rem;
	}
	.muted {
		margin: 0 0 1rem;
	}
	.lrow {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		padding: 0.7rem 0;
		border-top: 1px solid var(--border);
		color: var(--text);
	}
	.lrow:first-of-type {
		border-top: none;
	}
	.cnt {
		display: inline-flex;
		align-items: center;
		gap: 0.3rem;
		color: var(--muted);
		font-size: 0.9rem;
	}
</style>
