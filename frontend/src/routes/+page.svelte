<script lang="ts">
	import { auth } from '$lib/auth.svelte';
	import { api, type LeagueSummary } from '$lib/api';
	import { Telescope, Volleyball, Trophy, Users, ChevronRight } from '@lucide/svelte';

	let leagues = $state<LeagueSummary[]>([]);
	let loaded = $state(false);

	$effect(() => {
		if (!auth.isAuthed) return;
		api
			.myLeagues()
			.then((r) => (leagues = r.leagues))
			.catch(() => {})
			.finally(() => (loaded = true));
	});

	const moves = [
		{
			href: '/tips',
			icon: Volleyball,
			title: 'Pronosticá los próximos partidos',
			sub: 'Predicciones de resultado, editables hasta el pitazo'
		},
		{
			href: '/forecast',
			icon: Telescope,
			title: 'Completá tu Predicción Inicial',
			sub: 'Tu pronóstico del torneo completo — antes del primer partido'
		},
		{
			href: '/leagues/xqrbkeemb72nagv',
			icon: Trophy,
			title: 'Mirá las posiciones de los participantes',
			sub: 'También podés revisar sus predicciones'
		}
	];
</script>

<header>
	<p class="kicker">Centro de Partidos</p>
	<h1>Hola,&nbsp;{auth.user?.name}</h1>
	<p class="muted sd">Mundial 2026 · 11 Jun – 19 Jul · 48 selecciones</p>
</header>

<div class="stagger">
<section class="card">
	<h3>Tus próximos pasos</h3>
	<div class="moves">
		{#each moves as m (m.href)}
			{@const Icon = m.icon}
			<a class="move" href={m.href}>
				<span class="mi"><Icon size={20} /></span>
				<span class="mt">
					<span class="title">{m.title}</span>
					<span class="muted sub">{m.sub}</span>
				</span>
				<ChevronRight size={18} class="cr" />
			</a>
		{/each}
	</div>
</section>
</div>

<style>
	header {
		margin: 0.25rem 0 1.25rem;
	}
	h1 {
		margin: 0;
		font-size: 1.6rem;
	}
	header .muted {
		margin: 0.2rem 0 0;
	}
	.moves {
		margin-top: 0.6rem;
	}
	.move {
		display: flex;
		align-items: center;
		gap: 0.85rem;
		padding: 0.75rem 0;
		border-top: 1px solid var(--border);
		color: var(--text);
	}
	.move:first-child {
		border-top: none;
	}
	.mi {
		display: grid;
		place-items: center;
		width: 38px;
		height: 38px;
		border-radius: var(--radius-sm);
		background: var(--surface-2);
		color: var(--accent);
		flex: none;
	}
	.mt {
		display: flex;
		flex-direction: column;
	}
	.title {
		font-weight: 600;
	}
	.sub {
		font-size: 0.82rem;
	}
	:global(.move .cr) {
		margin-left: auto;
		color: var(--muted);
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
