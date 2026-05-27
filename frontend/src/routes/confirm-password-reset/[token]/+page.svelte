<script lang="ts">
	import { auth } from '$lib/auth.svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';

	let token = $derived($page.params.token ?? '');
	let password = $state('');
	let confirm = $state('');
	let busy = $state(false);
	let error = $state('');
	let done = $state(false);

	async function submit(e: Event) {
		e.preventDefault();
		error = '';
		if (password.length < 8) {
			error = 'La contraseña debe tener al menos 8 caracteres.';
			return;
		}
		if (password !== confirm) {
			error = 'Las contraseñas no coinciden.';
			return;
		}
		busy = true;
		try {
			await auth.confirmPasswordReset(token, password, confirm);
			done = true;
			// PocketBase invalida la sesión después de un restablecimiento — nos aseguramos
			// de limpiar cualquier residuo obsoleto y enviamos al usuario a iniciar sesión de cero.
			auth.logout();
			setTimeout(() => goto('/login'), 1200);
		} catch (err: unknown) {
			error =
				(err as { message?: string })?.message ??
				'Este enlace de restablecimiento es inválido o ha expirado.';
		} finally {
			busy = false;
		}
	}
</script>

<div class="auth">
	<h1>Elegir nueva contraseña</h1>
	<p class="muted">Ingresá y confirmá tu nueva contraseña de acceso.</p>

	{#if done}
		<div class="card">
			<p class="ok">Contraseña actualizada — redirigiéndote al inicio de sesión…</p>
		</div>
	{:else}
		<form class="card" onsubmit={submit}>
			<div class="field">
				<label for="pw">Nueva contraseña</label>
				<input
					id="pw"
					class="input"
					type="password"
					bind:value={password}
					autocomplete="new-password"
					minlength="8"
					required
				/>
			</div>
			<div class="field">
				<label for="pw2">Confirmar nueva contraseña</label>
				<input
					id="pw2"
					class="input"
					type="password"
					bind:value={confirm}
					autocomplete="new-password"
					minlength="8"
					required
				/>
			</div>
			{#if error}<p class="error">{error}</p>{/if}
			<button class="btn" disabled={busy || !token}>
				{busy ? 'Actualizando…' : 'Actualizar contraseña'}
			</button>
			<p class="muted switch"><a href="/login">Volver a iniciar sesión</a></p>
		</form>
	{/if}
</div>

<style>
	/* El bloque CSS se mantiene intacto */
	.auth {
		max-width: 360px;
		margin: 8vh auto 2rem;
		padding: 0 1rem;
	}
	h1 {
		font-family: var(--font-display);
		font-size: 2.2rem;
		text-transform: uppercase;
		margin: 0 0 0.25rem;
		text-align: center;
	}
	p.muted {
		text-align: center;
		margin: 0 0 2rem;
		font-size: 0.95rem;
	}
	.card {
		background: var(--surface);
		border: 1px solid var(--border);
		border-radius: var(--radius);
		padding: 1.5rem;
		display: flex;
		flex-direction: column;
		gap: 1.1rem;
		box-shadow: var(--shadow-sm);
	}
	.error {
		margin: 0;
		background: var(--danger-subtle, #fde8e8);
		color: var(--danger, #e02424);
		border: 1px solid var(--danger-border, #f8b4b4);
		padding: 0.55rem 0.75rem;
		border-radius: var(--radius-sm);
		font-size: 0.85rem;
		font-weight: 500;
	}
	.ok {
		margin: 0;
		background: rgba(22, 163, 74, 0.1);
		color: #16a34a;
		border: 1px solid rgba(22, 163, 74, 0.2);
		padding: 0.55rem 0.75rem;
		border-radius: var(--radius-sm);
		font-size: 0.85rem;
		font-weight: 500;
	}
	.field {
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
	}
	label {
		font-size: 0.75rem;
		font-weight: 700;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: var(--muted);
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
	input:focus {
		outline: none;
		border-color: var(--accent);
	}
	.switch {
		text-align: center;
		margin: 0.4rem 0 0;
		font-size: 0.9rem;
		font-weight: 600;
		text-decoration: underline;
	}
</style>
